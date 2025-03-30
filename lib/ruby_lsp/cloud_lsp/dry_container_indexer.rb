# typed: true

require_relative 'logger'

module RubyLsp
  module CloudLsp
    class DryContainerIndexer
      extend T::Sig
      include Logger

      sig { returns(T.nilable(Hash)) }
      attr_reader :deps

      sig { params(path: String).void }
      def initialize(path)
        @path       = path
        @deps       = T.let({}, T::Hash[T.untyped, T.untyped])
        @resolution = T.let({}, T::Hash[T.untyped, T.untyped])
        @files      = T.let({}, T::Hash[T.untyped, T.untyped])
      end

      sig { returns([T::Hash[T.untyped, T.untyped], T::Hash[T.untyped, T.untyped], T::Hash[T.untyped, T.untyped]]) }
      def index
        deps = Dir["#{@path}/config/**/*.rb"].find do |file|
          File.read(file).include?("Dry::Container::Mixin")
        end
        log "Found Dry::Container at #{deps}"

        parse_result = Prism.parse_file(deps)
        data = RegisterCallCollector.new
        data.visit(parse_result.value)

        @deps = data.mapping
        dependency_resolution

        data = NameCollector.new
        Dir["#{@path}/app/**/*.rb"].each do |file|
          source = File.read(file)
          parsed = Prism.parse(source)
          data.reset
          data.visit(parsed.value)

          next if data.key.nil?
          next unless @deps.values.include? data.key

          @files[data.key] = file
        end

        [@deps, @resolution, @files]
      end

      def dependency_resolution
        files = Dir["#{@path}/app/**/*.rb"].select do |file|
          File.read(file).include?("include DI")
        end

        files.each do |file|
          source = File.read(file)
          parsed = Prism.parse(source)
          resolve = ResolutionIncludeCollector.new
          resolve.visit(parsed.value)
          @resolution.merge!(resolve.mapping)
        end
      end

      class NameCollector < Prism::Visitor
        attr_reader :mapping, :module_stack
        def initialize
          reset
          super
        end

        def reset
          @module_stack  = []
          @current_class = nil
          @mapping       = {}
        end

        def visit_module_node(node)
          @module_stack.push(constant_name(node.constant_path)) if node.constant_path
          super
          @module_stack.pop
        end

        def visit_class_node(node)
          class_name = constant_name(node.constant_path)
          return unless class_name

          @module_stack.push(class_name)

          full_name = @module_stack.join("::")

          @mapping[full_name] ||= {}
          @current_class = full_name
          super
          @module_stack.pop
          @current_class = @module_stack.nil? ? nil : @module_stack.join("::")
        end

        def visit_call_node(node)
          return @module_stack.inspect
        end

        def constant_name(node)
          return unless node

          case node
          when Prism::ConstantReadNode
            node.name
          when Prism::ConstantPathNode
            [constant_name(node.parent), node.name].compact.join("::")
          else
            nil
          end
        end
        def key
          @mapping.keys.last
        end
      end

      class ResolutionIncludeCollector < Prism::Visitor
        attr_reader :mapping

        def initialize
          @mapping = {}
          @module_stack = []
          @current_class = nil
          super()
        end

        def visit_module_node(node)
          @module_stack.push(constant_name(node.constant_path)) if node.constant_path
          super
          @module_stack.pop
        end

        def visit_class_node(node)
          class_name = constant_name(node.constant_path)
          return unless class_name

          @module_stack.push(class_name)
          full_name = @module_stack.join("::")

          @mapping[full_name] ||= {}
          @current_class = full_name
          super
          @module_stack.pop
          @current_class = nil
        end

        def visit_call_node(node)
          return unless node.name == :include

          first_arg = node.arguments&.arguments.first
          return unless first_arg.is_a?(Prism::CallNode)
          return unless first_arg.name == :[]
          return unless first_arg.receiver
          return unless first_arg.receiver.is_a?(Prism::ConstantReadNode) && T.cast(first_arg.receiver, Prism::ConstantReadNode).name == :DI

          first_arg_args = first_arg.arguments&.arguments
          return unless first_arg_args&.any?

          first_arg_args.each do |element|
            case element
            when Prism::SymbolNode
              @mapping[@current_class][element.value.to_s] = element.value.to_s
            when Prism::KeywordHashNode
              element.elements.each do |el|
                el = T.cast(el, Prism::AssocNode)
                if el.key.is_a?(Prism::SymbolNode) && el.value.is_a?(Prism::StringNode)
                  key   = T.cast(el.key, Prism::SymbolNode)
                  value = T.cast(el.value, Prism::StringNode)

                  @mapping[@current_class][key.value.to_s] = value.unescaped
                end
              end
            else
              # do nothing
            end
          end

          super
        end

        private

        def constant_name(node)
          return unless node

          case node
          when Prism::ConstantReadNode
            node.name
          when Prism::ConstantPathNode
            [constant_name(node.parent), node.name].compact.join("::")
          else
            nil
          end
        end
      end

      # require 'prism'
      # require 'debug'
      class RegisterCallCollector < Prism::Visitor
        attr_reader :mapping, :nesting

        def initialize
          @mapping = {} # final { 'key' => 'Constant::Name' } result
          @nesting = []
          super()
        end

        def visit_class_node(node)
          @nesting.push constant_name(node.constant_path)
          super
          @nesting.pop
        end

        def visit_module_node(node)
          @nesting.push constant_name(node.constant_path)
          super
          @nesting.pop
        end

        def visit_call_node(node)
          if node.name == :register
            key = extract_register_key(node)
            value = extract_block_constant(node.block)

            @mapping[key] = value if key && value
          end
          super
        end

        private

        def extract_register_key(node)
          arg = node.arguments.arguments.first
          case arg
          when Prism::SymbolNode
            arg.value.to_s
          when Prism::StringNode
            arg.unescaped
          end
        end

        def extract_block_constant(block)
          return nil unless block
          body = block.body
          return nil unless body

          body = block.body.body[0] if block.body.is_a? Prism::StatementsNode

          case body
          when Prism::CallNode
            receiver = body.receiver
            if receiver.is_a?(Prism::ConstantPathNode)
              return constant_name(receiver)
            end
          when Prism::ConstantReadNode
            return body.name
          when Prism::ConstantPathNode
            return constant_name(body)
          end
        end

        def constant_name(node)
          return nil unless node

          case node
          when Prism::ConstantReadNode
            node.name
          when Prism::ConstantPathNode
            [constant_name(node.parent), node.name].compact.join("::")
          end
        end
      end
    end
  end
end
