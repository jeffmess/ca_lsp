require 'ruby_lsp/addon'

module RubyLsp
  module CloudLsp
    class DryHover
      include Requests::Support::Common

      def initialize(response_builder, helpers_hash, docs, dispatcher)
        STDERR.puts "[CloudLSP] Initialize DryHover"

        @response_builder = response_builder
        @helpers_hash     = helpers_hash
        @docs             = docs

        dispatcher.register(self, :on_call_node_enter)
      end

      def on_call_node_enter(node)
        docs = @docs[node.name]

        @response_builder.push(docs[:yard_doc], category: :documentation)
      end
    end
  end
end
