require 'ruby_lsp/addon'

module RubyLsp
  module CloudLsp

    class Completion
      include Requests::Support::Common
      def initialize(response_builder, helpers_hash, docs, dispatcher)
        @response_builder = response_builder
        @helpers_hash     = helpers_hash
        @docs             = docs
        dispatcher.register(self, :on_call_node_enter) #, RubyLsp::Interface::CompletionParams)
      end


      def on_call_node_enter(node)
        # log "on call node"
        # log "DCall node?#{node.is_a?(Prism::CallNode)}"
        # log "includes? #{node.name}"

        # log @helpers_hash.keys
        STDERR.puts "node name: #{node.name}"
        # return unless node.name.start_with?('ui_') || node.name.start_with?('ca_')

        location = node.location

        @helpers_hash.each do |key, value|
          detail      = @docs[key]
          signature   = detail.nil? ? value : detail[:signature]
          insert_text = detail.nil? ? "#{key}()" : "#{key}#{detail[:insert_text]}"
          yard        = detail.nil? ? "" : detail[:yard_doc]
          yard        = "#{yard}\nDefault\n#{key}#{signature} -> #{value}"

          @response_builder << RubyLsp::Interface::CompletionItem.new(
            label: key,
            kind: RubyLsp::Constant::CompletionItemKind::VARIABLE,
            detail: yard, #"#{key}#{signature} → #{value}",
            documentation: {
              kind: "markdown",
              value: "Custom method from your addon"
            },
            insert_text:,
            insert_text_format: RubyLsp::Constant::InsertTextFormat::SNIPPET
          )
        end
      end
    end   
  end
end
