require 'ruby_lsp/addon'

module RubyLsp
  module CloudLsp
    class Definition
      include Requests::Support::Common

      def initialize(response_builder, deps, docs, dispatcher)
        @response_builder = response_builder
        @deps             = deps
        @docs             = docs

        dispatcher.register(self, :on_call_node_enter)
      end

      def on_call_node_enter(node)
        detail = @docs[node.name]

        @response_builder << RubyLsp::Interface::Location.new(
          uri: "file://#{detail[:path]}",
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
