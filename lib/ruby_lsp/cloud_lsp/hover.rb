require "ruby_lsp/addon"

module RubyLsp
  module CloudLsp
    class Hover
      include Requests::Support::Common
      include Logger

      def initialize(response_builder, helpers_hash, docs, class_to_helper_mapping, service_classes, service_docs, dispatcher)
        @response_builder = response_builder
        @helpers_hash = helpers_hash
        @docs = docs
        @class_to_helper_mapping = class_to_helper_mapping
        @service_classes = service_classes
        @service_docs = service_docs

        dispatcher.register(self, :on_call_node_enter)
      end

      def on_call_node_enter(node)
        # Handle direct helper method calls (existing functionality)
        log("Node name: #{node.name}")

        if @docs[node.name]
          docs = @docs[node.name]
          @response_builder.push(docs[:yard_doc], category: :documentation)
          return
        end

        # Handle ViewComponent.new calls - map to initialize documentation
        if node.name == :new && node.receiver
          receiver_name = extract_receiver_name(node.receiver)
          if receiver_name
            log "Checking ViewComponent receiver: #{receiver_name}"
            # Use the class-to-helper mapping to find the helper method
            component_helper = @class_to_helper_mapping[receiver_name]
            if component_helper && @docs[component_helper]
              log "Found ViewComponent mapping: #{receiver_name} -> #{component_helper}"
              docs = @docs[component_helper]
              # Push our documentation with high priority to override built-in docs
              @response_builder.push(docs[:yard_doc], category: :documentation)
              # Also push as a different category to ensure visibility
              @response_builder.push("**ViewComponent:** #{docs[:yard_doc]}", category: :view_component)
              return
            end
          end
        end

        # Handle ServiceObject.call calls - map to initialize documentation
        if node.name == :call && node.receiver
          receiver_name = extract_receiver_name(node.receiver)
          if receiver_name && @service_classes && @service_classes[receiver_name]
            docs = @service_docs[receiver_name]
            if docs
              @response_builder.push(docs[:yard_doc], category: :documentation)
            end
          end
        end
      end

      private

      def extract_receiver_name(receiver_node)
        case receiver_node
        when Prism::ConstantReadNode
          receiver_node.name.to_s
        when Prism::ConstantPathNode
          # Handle namespaced constants like Users::CardComponent
          build_constant_path(receiver_node)
        else
          nil
        end
      end

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

    end
  end
end
