# typed: true

module RubyLsp
  module CloudLsp
    class DryContainerIndexer
      extend T::Sig

      sig { returns(T.nilable(Hash)) }
      attr_reader :deps

      sig { params(path: String).void }
      def initialize(path)
        @path = path
        @deps = T.let({}, T::Hash[T.untyped, T.untyped])
        @resolution = T.let({}, T::Hash[T.untyped, T.untyped])
        @files = T.let({}, T::Hash[T.untyped, T.untyped])
      end

      sig { returns(T::Array[T::Hash[T.untyped, T.untyped]]) }
      def index
        # Currently does double the amount of work it needs to
        # TODO: refactor
        STDERR.puts "Indexing Dry Container"

        deps = Dir["#{@path}/config/**/*.rb"].find do |file|
          File.read(file).include?("Dry::Container::Mixin")
        end
        STDERR.puts "  found: #{deps}"

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
          # STDERR.puts "-------> #{data.mapping} --> #{file} --> data.key"
          next if data.key.nil?
          # STDERR.puts "#{data.key}"
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
          @module_stack = []
          @current_class = nil
          @mapping = {}
        end

        def visit_module_node(node)
          @module_stack.push(constant_name(node.constant_path)) if node.constant_path
          super
          @module_stack.pop
        end

        def visit_class_node(node)
          # class_name = node.constant_path.source
          class_name = constant_name(node.constant_path)
          return unless class_name

          full_name = [*@module_stack, class_name].join("::")

          @mapping[full_name] ||= {}
          @current_class = full_name
          super
          @current_class = nil
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
          @mapping.keys[0]
        end
      end
      # x = NameCollector.new
      # x.visit(data.value)

      # data = Prism.parse_file('/Users/jeff/projects/ruby/cloudassess/app/services/services/onboarding/enrol_myself.rb')
      # x = ResolutionIncludeCollector.new
      # x.visit(data.value)

      class ResolutionIncludeCollector < Prism::Visitor
        attr_reader :mapping

        def initialize
          @mapping = {}
          @module_stack = []
          @current_class = nil
          super()
        end

        def visit_module_node(node)
          # @module_stack.push(node.constant_path.source) if node.constant_path

          @module_stack.push(constant_name(node.constant_path)) if node.constant_path
          super
          @module_stack.pop
        end

        def visit_class_node(node)
          # class_name = node.constant_path.source
          class_name = constant_name(node.constant_path)
          return unless class_name

          full_name = [*@module_stack, class_name].join("::")
          @mapping[full_name] ||= {}
          @current_class = full_name
          super
          @current_class = nil
        end

        def visit_call_node(node)
          # puts "CALL NODE: #{node.name} RECEIVED BY: #{node.receiver&.name} <#{node.receiver}>"
          return unless node.name == :include
          # return unless node.receiver.is_a?(Prism::ConstantReadNode) && node.receiver.name == "DI"

          first_arg = node.arguments&.arguments.first # why?
          # puts "FIRST ARG: #{first_arg.name}"
          return unless first_arg.is_a?(Prism::CallNode)
          return unless first_arg.name == :[]
          return unless first_arg.receiver.is_a?(Prism::ConstantReadNode) && first_arg.receiver&.name == :DI
          # return unless first_arg.is_a?(Prism::ArrayNode)
          #
          first_arg_args = first_arg.arguments&.arguments
          puts "FIRS ARG ARGS: #{first_arg_args}"
          return unless first_arg_args&.any?

          first_arg_args.each do |element|
            case element
            when Prism::SymbolNode
              # include DI[:logger] -> { "logger" => "logger" }
              @mapping[@current_class][element.value.to_s] = element.value.to_s
            when Prism::AssocNode
              # include DI[myself: 'services.onboarding.enrol_myself']
              key = element.key
              values = element.value

              if key.is_a?(Prism::SymbolNode) && value.is_a?(Prism::StringNode)
                @mapping[@current_class][key.value.to_s] = value.unescaped
              end
            when Prism::KeywordHashNode
              element.elements.each do |el|
                if el.key.is_a?(Prism::SymbolNode) && el.value.is_a?(Prism::StringNode)
                  @mapping[@current_class][el.key.value.to_s] = el.value.unescaped
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
      # parse_result = Prism.parse_file("/Users/jeff/projects/ruby/cloudassess/config/initializers/system.rb")
      # collector = RegisterCallCollector.new
      # collector.visit(parse_result.value)
    end
  end
end
