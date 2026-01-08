require "ruby_lsp/addon"

module RubyLsp
  module CloudLsp
    class Completion
      include Requests::Support::Common
      include Logger

      def initialize(response_builder, helpers_hash, docs, class_to_helper_mapping, service_classes, service_docs, dispatcher, file_type = :ruby)
        @response_builder = response_builder
        @helpers_hash = helpers_hash
        @docs = docs
        @class_to_helper_mapping = class_to_helper_mapping
        @service_classes = service_classes
        @service_docs = service_docs
        @file_type = file_type
        dispatcher.register(self, :on_call_node_enter)
        dispatcher.register(self, :on_constant_read_node_enter)
        dispatcher.register(self, :on_constant_path_node_enter)
      end

      def on_call_node_enter(node)
        log "Call node entered: #{node.name}, receiver: #{node.receiver&.class}, file_type: #{@file_type}"
        
        # Handle ServiceObject call completion in Ruby files when receiver is a ServiceObject class
        if @file_type == :ruby && node.receiver && @service_classes
          receiver_name = extract_receiver_name(node.receiver)
          log "Checking receiver: #{receiver_name}"
          
          if receiver_name && @service_classes[receiver_name] && node.name == :call
            service_doc = @service_docs[receiver_name]
            if service_doc
              signature = service_doc[:signature] || "()"
              insert_text = service_doc[:insert_text] || "()"
              yard_doc = service_doc[:yard_doc] || ""

              @response_builder << RubyLsp::Interface::CompletionItem.new(
                label: "call",
                kind: RubyLsp::Constant::CompletionItemKind::METHOD,
                detail: "#{receiver_name}.call#{signature}",
                documentation: {
                  kind: "markdown",
                  value: "ServiceObject call method\n\n#{yard_doc}",
                },
                insert_text: "call#{insert_text}",
                insert_text_format: RubyLsp::Constant::InsertTextFormat::SNIPPET,
              )
            end
          end
        end
        
        # Only show ViewComponent helper methods in HAML files
        return unless @file_type == :haml

        location = node.location

        @helpers_hash.each do |key, value|
          detail = @docs[key]
          signature = detail.nil? ? value : detail[:signature]
          insert_text = detail.nil? ? "#{key}()" : "#{key}#{detail[:insert_text]}"
          yard = detail.nil? ? "" : detail[:yard_doc]
          yard = "#{yard}\nDefault\n#{key}#{signature} -> #{value}"

          @response_builder << RubyLsp::Interface::CompletionItem.new(
            label: key,
            kind: RubyLsp::Constant::CompletionItemKind::VARIABLE,
            detail: signature,
            documentation: {
              kind: "markdown",
              value: "ViewComponent helper method",
            },
            insert_text:,
            insert_text_format: RubyLsp::Constant::InsertTextFormat::SNIPPET,
          )
        end
      end

      def on_constant_read_node_enter(node)
        # Only show ServiceObject completion in Ruby files
        return unless @file_type == :ruby
        return unless @service_classes

        log "Constant read node: #{node.name}"

        constant_name = node.name.to_s

        # Check if this constant matches any of our ServiceObject classes exactly
        if @service_classes[constant_name]
          service_doc = @service_docs[constant_name]
          if service_doc
            signature = service_doc[:signature] || "()"
            insert_text = service_doc[:insert_text] || "()"
            yard_doc = service_doc[:yard_doc] || ""

            @response_builder << RubyLsp::Interface::CompletionItem.new(
              label: "call",
              kind: RubyLsp::Constant::CompletionItemKind::METHOD,
              detail: "#{constant_name}.call#{signature}",
              documentation: {
                kind: "markdown",
                value: "ServiceObject call method\n\n#{yard_doc}",
              },
              insert_text: "call#{insert_text}",
              insert_text_format: RubyLsp::Constant::InsertTextFormat::SNIPPET,
            )
          end
        end
      end

      def on_constant_path_node_enter(node)
        # Only show ServiceObject completion in Ruby files
        return unless @file_type == :ruby
        return unless @service_classes

        # Build the full constant path
        constant_name = build_constant_path(node)

        log "Constant path node: #{constant_name}"

        # Check if this constant matches any of our ServiceObject classes
        if @service_classes[constant_name]
          service_doc = @service_docs[constant_name]
          if service_doc
            signature = service_doc[:signature] || "()"
            insert_text = service_doc[:insert_text] || "()"
            yard_doc = service_doc[:yard_doc] || ""

            @response_builder << RubyLsp::Interface::CompletionItem.new(
              label: "call",
              kind: RubyLsp::Constant::CompletionItemKind::METHOD,
              detail: "#{constant_name}.call#{signature}",
              documentation: {
                kind: "markdown",
                value: "ServiceObject call method\n\n#{yard_doc}",
              },
              insert_text: "call#{insert_text}",
              insert_text_format: RubyLsp::Constant::InsertTextFormat::SNIPPET,
            )
          end
        end
      end

      private

      def build_constant_path(node)
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

        parts.join("::")
      end

      def extract_receiver_name(receiver_node)
        case receiver_node
        when Prism::ConstantReadNode
          receiver_node.name.to_s
        when Prism::ConstantPathNode
          build_constant_path(receiver_node)
        else
          nil
        end
      end
    end
  end
end
