# typed: strict

require "ruby_lsp/addon"
require "ruby_lsp/internal"

require_relative "view_component_indexer"
require_relative "hover"
require_relative "completion"
require_relative "definition"

module RubyLsp
  module CloudLsp

    class Addon < ::RubyLsp::Addon
      extend T::Sig

      sig { void }
      def initialize
        super

        @view_component_indexer = T.let(nil, T.nilable(ViewComponentIndexer))
        @deps                   = T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
        @docs                   = T.let(nil, T.nilable(T::Hash[T.untyped, T.untyped]))
      end
      
      sig { params(global_state: T.untyped, message_queue: T.untyped).void }
      def activate(global_state, message_queue)
        STDERR.puts "Activating the Cloud LSP #{version}"
        STDERR.puts "Initializing from #{Dir.pwd}"

        @view_component_indexer ||= ViewComponentIndexer.new(Dir.pwd)
        @deps, @docs              = @view_component_indexer.index

        # STDERR.puts @deps.keys
        STDERR.puts "[CloudLSP] loaded successfully."
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
          uri: URI::Generic
        ).void
      end
      def create_completion_listener(response_builder, node_context, dispatcher, uri)
        STDERR.puts "[CloudLSP] #{uri}"
        if T.must(uri.path).end_with? '.haml'
          STDERR.puts "[CloudLSP]: Working on #{uri}"
          Completion.new(response_builder, @deps, @docs, dispatcher)
        end
      end

      sig do
        params(
          response_builder: ResponseBuilders::CollectionResponseBuilder,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher
        ).void
      end
      def create_hover_listener(response_builder, node_context, dispatcher)
        return unless node_context.node.respond_to? :name
        return unless T.must(@deps)[node_context.node.name]

        Hover.new(response_builder, @deps, @docs, dispatcher)
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
        return unless T.must(@deps)[node_context.node.name]

        Definition.new(response_builder, @deps, @docs, dispatcher)
      end
    end
  end
end
