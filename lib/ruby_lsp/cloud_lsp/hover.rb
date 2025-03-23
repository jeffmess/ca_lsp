require 'ruby_lsp/addon'

module RubyLsp
  module CloudLsp
    class Hover
      include Requests::Support::Common

      # Listeners are initialized with the Prism::Dispatcher. This object is used by the Ruby LSP to emit the events
      # when it finds nodes during AST analysis. Listeners must register which nodes they want to handle with the
      # dispatcher (see below).
      # Listeners are initialized with a `ResponseBuilders` object. The listener will push the associated content
      # to this object, which will then build the Ruby LSP's response.
      # Additionally, listeners are instantiated with a message_queue to push notifications (not used in this example).
      # See "Sending notifications to the client" for more information.
      def initialize(response_builder, helpers_hash, docs, dispatcher)
        STDERR.puts "[CloudLSP] Initialize Hover"

        @response_builder = response_builder
        @helpers_hash     = helpers_hash
        @docs             = docs

        dispatcher.register(self, :on_constant_read_node_enter, :on_call_node_enter)
      end

      def on_call_node_enter(node)
        docs = @docs[node.name]

        @response_builder.push(docs[:yard_doc], category: :documentation)
      end

      # Listeners must define methods for each event they registered with the dispatcher. In this case, we have to
      # define `on_constant_read_node_enter` to specify what this listener should do every time we find a constant
      def on_constant_read_node_enter(node)
        @response_builder.push("Hello!", category: :documentation)
      end
    end
  end
end
