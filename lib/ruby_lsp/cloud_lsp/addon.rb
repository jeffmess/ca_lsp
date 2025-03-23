require "ruby_lsp/addon"

module RubyLsp
  module CloudLsp
    class Addon < ::RubyLsp::Addon
      extend T::Sig
      
      sig { override.params(message_queue: Thread::Queue).void }
      def activate(global_state, message_queue)
        require_relative "view_component_indexer"
        require_relative "hover"
        require_relative "completion"
        require_relative "definition"

        STDERR.puts "Activating the Cloud LSP #{version}"
        STDERR.puts "Initializing from #{Dir.pwd}"

        @view_component_indexer ||= RubyLsp::CloudLsp::ViewComponentIndexer.new(Dir.pwd)
        @deps, @docs = @view_component_indexer.index

        # STDERR.puts @deps.keys
        STDERR.puts "[CloudLSP] loaded successfully."
      end

      # Performs any cleanup when shutting down the server, like terminating a subprocess
      sig { override.void }
      def deactivate
      end

      # Returns the name of the addon
      sig { override.returns(String) }
      def name
        "Cloud LSP"
      end

      sig { override.returns(String) }
      def version
        "0.1.0"
      end

      def create_completion_listener(response_builder, node_context, dispatcher, uri)
        STDERR.puts "[CloudLSP] #{uri}"
        if uri.path.end_with? '.haml'
          STDERR.puts "[CloudLSP]: Working on #{uri}"
          Completion.new(response_builder, @deps, @docs, dispatcher)
        end
      end

      def create_hover_listener(response_builder, node_context, dispatcher)
        return unless node_context.node.respond_to? :name
        # return if node_context.node.is_a? Prism::ProgramNode
        return unless @deps[node_context.node.name]

        Hover.new(response_builder, @deps, @docs, dispatcher)
      end

      def create_definition_listener(response_builder, uri, node_context, dispatcher)
        return unless @deps[node_context.node.name]

        STDERR.puts "Register goto def dispatcher"

        Definition.new(response_builder, @deps, @docs, dispatcher)
      end
    end
  end
end
