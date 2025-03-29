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
        @deps = T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
      end

      # sig { returns(T.nilable([T::Hash[T.untyped, T.untyped], T::Hash[T.untyped, T.untyped]])) }
      def index
        STDERR.puts "Indexing Dry Container"

        deps = Dir["#{@path}/config/**/*.rb"].find do |file|
          File.read(file).include?("Dry::Container::Mixin")
        end
        STDERR.puts "  found: #{deps}"

        parse_result = Prism.parse_file(deps)
        data = RegisterCallCollector.new
        data.visit(parse_result.value)

        @deps = data.mapping
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
