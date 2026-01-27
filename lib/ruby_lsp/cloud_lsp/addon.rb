require "ruby_lsp/addon"
require "ruby_lsp/internal"

require_relative "view_component_indexer"
require_relative "service_object_indexer"
require_relative "hover"
require_relative "completion"
require_relative "definition"
require_relative "logger"

module RubyLsp
  module CloudLsp
    class Addon < ::RubyLsp::Addon
      include Logger

      def initialize
        super

        @view_component_indexer = nil
        @service_object_indexer = nil
        @deps = {}
        @docs = nil
        @class_to_helper_mapping = {}
        @component_classes = {}
        @service_classes = {}
        @service_docs = {}
      end

      def activate(global_state, message_queue)
        log "Activating..."
        log "Initializing from #{Dir.pwd}"

        time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        @view_component_indexer ||= ViewComponentIndexer.new(Dir.pwd)
        @service_object_indexer ||= ServiceObjectIndexer.new(Dir.pwd)
        @deps, @docs = @view_component_indexer.index
        @class_to_helper_mapping = @view_component_indexer.class_to_helper_mapping
        @component_classes = @view_component_indexer.component_classes
        @service_classes, @service_docs = @service_object_indexer.index

        duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - time) * 1000).round(2)
        log "Indexing took #{duration_ms}ms"
        log "loaded successfully"
      end

      def deactivate
      end

      # Returns the name of the addon
      def name
        "Cloud LSP"
      end

      def version
        "0.1.0"
      end

      def create_completion_listener(response_builder, node_context, dispatcher, uri)
        file_path = uri.path
        
        # Handle ViewComponent completion in HAML files
        if file_path.end_with? ".haml"
          return Completion.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher, :haml)
        end

        # Handle ServiceObject completion in Ruby files
        if file_path.end_with? ".rb"
          return Completion.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher, :ruby)
        end

        nil
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        return unless node_context.node.respond_to? :name

        # Check for ViewComponent helper methods
        if @deps[node_context.node.name]
          return Hover.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher)
        end

        # Check for ViewComponent.new calls (prioritize this to override built-in documentation)
        if node_context.node.name == :new && node_context.node.receiver
          receiver_name = extract_receiver_name_from_node(node_context.node.receiver)
          if receiver_name && (@class_to_helper_mapping[receiver_name] || @component_classes[receiver_name])
            log "Creating hover listener for ViewComponent: #{receiver_name}"
            return Hover.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher)
          end
        end

        # Check for ServiceObject.call methods or direct class references
        if node_context.node.name == :call && node_context.node.receiver ||
           @service_classes.keys.any? { |class_name| class_name.include?(node_context.node.name.to_s) }
          return Hover.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher)
        end

        nil
      end

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

      def create_definition_listener(response_builder, uri, node_context, dispatcher)
        return if node_context.node.is_a? Prism::SymbolNode # We do not process symbol nodes for view components
        return if node_context.node.is_a? Prism::ProgramNode # Copilot doing something strange here?
        return unless node_context.node.respond_to?(:name)

        # Check for ViewComponent helper methods
        if @deps[node_context.node.name]
          return Definition.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher)
        end

        # Check for ServiceObject.call methods
        if node_context.node.name == :call && node_context.node.receiver ||
           @service_classes.keys.any? { |class_name| class_name.include?(node_context.node.name.to_s) }
          return Definition.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher)
        end

        # Check for ViewComponent.new calls
        if node_context.node.name == :new && node_context.node.receiver
          return Definition.new(response_builder, @deps, @docs, @class_to_helper_mapping, @component_classes, @service_classes, @service_docs, dispatcher)
        end

        nil
      end
    end
  end
end
