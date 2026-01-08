# typed: false
require 'ruby_lsp/addon'

module RubyLsp
  module CloudLsp
    class Definition
      include Requests::Support::Common

      def initialize(response_builder, deps, docs, class_to_helper_mapping, service_classes, service_docs, dispatcher)
        @response_builder = response_builder
        @deps             = deps
        @docs             = docs
        @class_to_helper_mapping = class_to_helper_mapping
        @service_classes  = service_classes
        @service_docs     = service_docs

        dispatcher.register(self, :on_call_node_enter)
      end

      def on_call_node_enter(node)
        # Handle direct helper method calls (existing ViewComponent functionality)
        if @docs[node.name]
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
          return
        end

        # Handle ViewComponent.new calls
        if node.name == :new && node.receiver
          receiver_name = extract_receiver_name(node.receiver)
          if receiver_name
            # Use the class-to-helper mapping to find the helper method
            component_helper = @class_to_helper_mapping[receiver_name]
            if component_helper && @docs[component_helper]
              detail = @docs[component_helper]
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
              return
            end
          end
        end

        # Handle ServiceObject.call calls
        if node.name == :call && node.receiver
          receiver_name = extract_receiver_name(node.receiver)
          if receiver_name && @service_classes && @service_classes[receiver_name]
            file_path = @service_classes[receiver_name]
            @response_builder << RubyLsp::Interface::Location.new(
              uri: "file://#{file_path}",
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
        
        parts.join('::')
      end

    end
  end
end
