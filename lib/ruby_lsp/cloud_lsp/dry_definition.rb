require 'ruby_lsp/addon'

module RubyLsp
  module CloudLsp
    class DryDefinition # < RubyLsp::Listeners::Definition
      attr_accessor :deps
      # include Requests::Support::Common

      def initialize(response_builder, deps, files, dispatcher)
        @response_builder = response_builder
        @deps             = deps
        @files            = files

        dispatcher.register(self, :on_call_node_enter)
      end

      def on_call_node_enter(node)
        STDERR.puts "#{__FILE__} #{__method__}: #{node.name} receiver: #{node.inspect}"
        STDERR.puts @deps
        STDERR.puts @files

        # @response_builder << RubyLsp::Interface::Location.new(
        #   uri: "file://#{detail[:path]}",
        #   range: RubyLsp::Interface::Range.new(
        #     start: RubyLsp::Interface::Position.new(
        #       line: 1,
        #       character: 1,
        #     ),
        #     end: RubyLsp::Interface::Position.new(line: 1, character: 1),
        #   ),
        # )
        # dependency_name = case node.receiver
        #                   when Prism::LocalVariableReadNode
        #                     node.receiver.name
        #                   when nil  
        #                     node.name
        #                   end

        # if dependency_name
        #   resolved_to = dry_container_indexer.resolve_dependency(dependency_name)
        #   STDERR.puts "RESOLVED #{dependency_name} to #{resolved_to}"

        #   STDERR.puts "LOOKING IN INDEX: #{resolved_to.inspect}"

        #   if resolved_to
        #     @_response = find_in_index(resolved_to).tap do |result|
        #       STDERR.puts "FOUND IN INDEX: #{result.inspect}"
        #     end
        #   end
        # end
      end
    end
  end
end
