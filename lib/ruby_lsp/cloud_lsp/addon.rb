# typed: strict

require "ruby_lsp/addon"
require "ruby_lsp/internal"

require_relative "view_component_indexer"
require_relative "dry_container_indexer"
require_relative "hover"
require_relative "completion"
require_relative "definition"
require_relative "dry_definition"

module RubyLsp
  module CloudLsp

    class Addon < ::RubyLsp::Addon
      extend T::Sig

      sig { void }
      def initialize
        super

        @view_component_indexer = T.let(nil, T.nilable(ViewComponentIndexer))
        @dry_container_indexer  = T.let(nil, T.nilable(DryContainerIndexer))
        @deps                   = T.let({}, T.nilable(T::Hash[T.untyped, T.untyped]))
        @docs                   = T.let(nil, T.nilable(T::Hash[T.untyped, T.untyped]))
        @di_deps                = T.let({}, T::Hash[T.untyped, T.untyped])
        @di_resolutions         = T.let({}, T::Hash[T.untyped, T.untyped])
        @di_files               = T.let({}, T::Hash[T.untyped, T.untyped])
      end
      
      sig { params(global_state: T.untyped, message_queue: T.untyped).void }
      def activate(global_state, message_queue)
        STDERR.puts "[Cloud LSP] Activating the Cloud LSP #{version}"
        STDERR.puts "[Cloud LSP] Initializing from #{Dir.pwd}"

        time = Time.now.to_i
        @view_component_indexer ||= ViewComponentIndexer.new(Dir.pwd)
        @dry_container_indexer  ||= DryContainerIndexer.new(Dir.pwd)
        @deps, @docs             = @view_component_indexer.index

        @di_deps, @di_resolutions, @di_files = @dry_container_indexer.index
        # STDERR.puts "[CloudLSP] #{@di_deps}"
        # STDERR.puts "[CLOUDLSP] #{@di_resolutions}"
        # STDERR.puts "[LSP] -> #{@di_files}"
        STDERR.puts "[CloudLSP] Indexing Duration: #{Time.now.to_i - time} seconds"

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
        STDERR.puts "GD -> #{node_context.node.name} | #{uri}"
        dry_definition_listener(response_builder, uri, node_context, dispatcher)
        return unless T.must(@deps)[node_context.node.name]

        Definition.new(response_builder, @deps, @docs, dispatcher)
      end

      sig do
        params(
          response_builder: ResponseBuilders::CollectionResponseBuilder,
          node_context: NodeContext,
          dispatcher: Prism::Dispatcher,
        ).void
      end
      def dry_definition_listener(response_builder, uri, node_context, dispatcher)
        data = DryContainerIndexer::NameCollector.new
        source = File.read(uri.path)
        parsed = Prism.parse(source)
        data.visit(parsed.value)

        return if data.key.nil?
        return unless @di_deps.values.include? data.key

        class_name = @di_resolutions[data.key][node_context.node.name.to_s]
        return unless @di_resolutions[data.key]
        return unless @di_resolutions[data.key][node_context.node.name.to_s]
        return unless @di_deps[class_name]

        file = @di_files[@di_deps[class_name]]

        response_builder << RubyLsp::Interface::Location.new(
          uri: "file://#{file}",
          range: RubyLsp::Interface::Range.new(
            start: RubyLsp::Interface::Position.new(
              line: 1,
              character: 1,
            ),
            end: RubyLsp::Interface::Position.new(line: 1, character: 1),
          ),
        )
      end
    end
  end
end
