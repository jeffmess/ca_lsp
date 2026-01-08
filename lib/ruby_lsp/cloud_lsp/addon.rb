# typed: strict

require "ruby_lsp/addon"
require "ruby_lsp/internal"

require_relative "view_component_indexer"
require_relative "service_object_indexer"
# require_relative "dry_container_indexer"
require_relative "hover"
require_relative "completion"
require_relative "definition"
require_relative "logger"

module RubyLsp
  module CloudLsp
    class Addon < ::RubyLsp::Addon
      extend T::Sig
      include Logger

      sig { void }

      def initialize
        super

        @view_component_indexer = T.let(nil, T.nilable(ViewComponentIndexer))
        @service_object_indexer = T.let(nil, T.nilable(ServiceObjectIndexer))
        # @dry_container_indexer  = T.let(nil, T.nilable(DryContainerIndexer))
        @deps = T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
        @docs = T.let(nil, T.nilable(T::Hash[T.untyped, T.untyped]))
        @class_to_helper_mapping = T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
        @service_classes = T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
        @service_docs = T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
        # @di_deps = T.let({}, T::Hash[T.untyped, T.untyped])
        # @di_resolutions = T.let({}, T::Hash[T.untyped, T.untyped])
        # @di_files = T.let({}, T::Hash[T.untyped, T.untyped])
      end

      sig { params(global_state: T.untyped, message_queue: T.untyped).void }

      def activate(global_state, message_queue)
        log "Activating..."
        log "Initializing from #{Dir.pwd}"

        time = Time.now.to_i
        @view_component_indexer ||= ViewComponentIndexer.new(Dir.pwd)
        @service_object_indexer ||= ServiceObjectIndexer.new(Dir.pwd)
        # @dry_container_indexer ||= DryContainerIndexer.new(Dir.pwd)
        @deps, @docs = @view_component_indexer.index
        @class_to_helper_mapping = @view_component_indexer.class_to_helper_mapping
        @service_classes, @service_docs = @service_object_indexer.index
        # @di_deps, @di_resolutions, @di_files = @dry_container_indexer.index

        log "Indexing took #{Time.now.to_i - time} seconds"
        log "loaded successfully"
      end

      sig { void }

      def deactivate
      end

      # Returns the name of the addon
      sig { returns(String) }

      def name
        "Cloud LSP"
      end

      sig { returns(String) }

      def version
        "0.1.0"
      end

      sig do
        params(
          response_builder: ResponseBuilders::CollectionResponseBuilder,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher,
          uri: URI::Generic,
        ).void
      end

      def create_completion_listener(response_builder, node_context, dispatcher, uri)
        file_path = T.must(uri.path)
        
        # Handle ViewComponent completion in HAML files
        if file_path.end_with? ".haml"
          return Completion.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher, :haml)
        end

        # Handle ServiceObject completion in Ruby files
        if file_path.end_with? ".rb"
          return Completion.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher, :ruby)
        end

        nil
      end

      sig do
        params(
          response_builder: ResponseBuilders::CollectionResponseBuilder,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher,
        ).void
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        return unless node_context.node.respond_to? :name

        # Check for ViewComponent helper methods
        if T.must(@deps)[node_context.node.name]
          return Hover.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher)
        end

        # Check for ViewComponent.new calls (prioritize this to override built-in documentation)
        if node_context.node.name == :new && node_context.node.receiver
          receiver_name = extract_receiver_name_from_node(node_context.node.receiver)
          if receiver_name && @class_to_helper_mapping[receiver_name]
            log "Creating hover listener for ViewComponent: #{receiver_name}"
            return Hover.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher)
          end
        end

        # Check for ServiceObject.call methods or direct class references
        if node_context.node.name == :call && node_context.node.receiver ||
           T.must(@service_classes).keys.any? { |class_name| class_name.include?(node_context.node.name.to_s) }
          return Hover.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher)
        end

        nil
      end

      private

      def extract_receiver_name_from_node(receiver_node)
        case receiver_node
        when Prism::ConstantReadNode
          receiver_node.name.to_s
        when Prism::ConstantPathNode
          build_constant_path_from_node(receiver_node)
        else
          nil
        end
      end

      def build_constant_path_from_node(node)
        parts = []
        current = node
        
        while current
          case current
          when Prism::ConstantPathNode
            parts.unshift(current.name.to_s)
            current = current.parent
          when Prism::ConstantReadNode
            parts.unshift(current.name.to_s)
            break
          else
            break
          end
        end
        
        parts.join('::')
      end

      sig do
        params(
          response_builder: ResponseBuilders::CollectionResponseBuilder,
          uri: URI::Generic,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher,
        ).void
      end

      def create_definition_listener(response_builder, uri, node_context, dispatcher)
        # dry_definition_listener(response_builder, uri, node_context, dispatcher)

        return if node_context.node.is_a? Prism::SymbolNode # We do not process symbol nodes for view components
        return if node_context.node.is_a? Prism::ProgramNode # Copilot doing something strange here?
        return unless node_context.node.respond_to?(:name)

        # Check for ViewComponent helper methods
        if T.must(@deps)[node_context.node.name]
          return Definition.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher)
        end

        # Check for ServiceObject.call methods
        if node_context.node.name == :call && node_context.node.receiver ||
           T.must(@service_classes).keys.any? { |class_name| class_name.include?(node_context.node.name.to_s) }
          return Definition.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher)
        end

        # Check for ViewComponent.new calls
        if node_context.node.name == :new && node_context.node.receiver
          return Definition.new(response_builder, @deps, @docs, @class_to_helper_mapping, @service_classes, @service_docs, dispatcher)
        end

        nil
      end

      sig do
        params(
          response_builder: ResponseBuilders::CollectionResponseBuilder,
          uri: URI::Generic,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher,
        ).void
      end

      # def dry_definition_listener(response_builder, uri, node_context, dispatcher)
      #   return unless node_context.node.is_a?(Prism::SymbolNode) ||
      #                 node_context.node.is_a?(Prism::StringNode) ||
      #                 node_context.node.is_a?(Prism::CallNode)

      #   data = DryContainerIndexer::NameCollector.new
      #   source = File.read(T.must(uri.path))
      #   parsed = Prism.parse(source)
      #   data.visit(parsed.value)

      #   return if data.key.nil?
      #   return unless @di_deps.values.include? data.key

      #   name = node_context.node.is_a?(Prism::SymbolNode) ? T.cast(node_context.node, Prism::SymbolNode).unescaped : node_context.node.name.to_s

      #   return unless @di_resolutions[data.key]
      #   return unless @di_resolutions[data.key][name]

      #   class_name = @di_resolutions[data.key][name]
      #   return unless @di_deps[class_name]

      #   file = @di_files[@di_deps[class_name]]

      #   return unless file

      #   response_builder << RubyLsp::Interface::Location.new(
      #     uri: "file://#{file}",
      #     range: RubyLsp::Interface::Range.new(
      #       start: RubyLsp::Interface::Position.new(
      #         line: 1,
      #         character: 1,
      #       ),
      #       end: RubyLsp::Interface::Position.new(line: 1, character: 1),
      #     ),
      #   )
      # end
    end
  end
end
