require 'yard'

module RubyLsp
  module CloudLsp
    class ViewComponentIndexer
      attr_reader :docs, :deps

      def initialize(path)
        @path = path
        @deps = {}
        @docs = {}
      end

      def index
        STDERR.puts "Indexing View Components"

        file_path = "#{@path}/app/helpers/cloud/view_helper.rb"
        return unless File.exist?(file_path)

        read_in_file(file_path)
        parse

        return [@deps, @docs]
      end

      def read_in_file(file_path)
        file_content = File.read(file_path)
        if file_content =~ /HELPERS = \{(.*?)\}/m
          helpers_content = $1 # This will give you the part between { and }
          @deps           = eval("{#{helpers_content}}") # Convert the extracted string back into a hash
        end
      end

      def parse
        @deps.each do |key, value|
          component_path = "#{@path}/app/components/#{transform_class_name(value)}"
          # STDERR.puts "Attempting to process #{component_path}"
          next unless File.exist?(component_path)

          file_code = File.read(component_path)
          result    = Prism.parse(file_code)
          _         = YARD.parse(component_path)
          ast       = result.value

          # TODO - clean this up and recurse
          class_node = ast.statements.body.find do |node|
            node.is_a?(Prism::ModuleNode) && %w[UI CA].include?(node.constant_path.full_name) # == "UI"
          end&.body&.body&.find do |node|
            node.is_a?(Prism::ClassNode) && node.constant_path.full_name.end_with?("Component") # == "LogoComponent"
          end

          next unless class_node

          initialize_node = class_node.body.body.find do |node|
            node.is_a?(Prism::DefNode) && node.name == :initialize
          end

          next unless initialize_node

          # Perform yard documentation
          class_docs = YARD::Registry.at(value).docstring
          method_docs = YARD::Registry.at("#{value}#initialize").tags.map do |tag|
            "  #{tag.tag_name} #{tag.name} [#{tag.types&.join(', ')}]: #{tag.text}\n"
          end

          docos = "#{class_docs}\n--------------\n#{method_docs.join}"

          @docs[key] = format_parameters_for_completion(initialize_node.parameters, docos).merge(path: component_path)
        end
      end

      def transform_class_name(class_name)
        class_name
          .gsub(/([A-Z])([A-Z])/, '\1_\2') # Insert underscore between consecutive uppercase letters (e.g., "CA" → "C_A")
          .gsub("::", "/")                 # Replace module separator with a slash
          .gsub(/([a-z\d])([A-Z])/, '\1_\2') # Convert CamelCase to snake_case
          .downcase + ".rb"                 # Convert to lowercase and append ".rb"
      end

      def format_parameters_for_completion(parameters_node, yard_doc = '')
        return {signature:'', text_input: '', yard: ''} if parameters_node.nil?
          # Start building parameter strings
        param_parts = []

        # Process required parameters
        parameters_node.requireds.each do |req|
          param_parts << req.name.to_s
        end

        # Process optional parameters
        parameters_node.optionals.each do |opt|
          default_value = extract_node_value(opt.value)
          param_parts << "#{opt.name} = #{default_value}"
        end

        # Process keyword parameters
        parameters_node.keywords.each do |kw|
         if kw.is_a?(Prism::OptionalKeywordParameterNode)
           default_value = extract_node_value(kw.value)
           param_parts << "#{kw.name}: #{default_value}"
         elsif kw.is_a?(Prism::RequiredKeywordParameterNode)
           # Required keywords don't have a default value
           param_parts << "#{kw.name}:"
         end

          # log(kw&.value&.nil?)
          # default_value = kw.value.nil? ? '' : extract_node_value(kw.value)
          # param_parts << "#{kw.name}: #{default_value}"
        end

        # Process keyword rest parameter
        if parameters_node.keyword_rest
          param_parts << "**#{parameters_node.keyword_rest.name}"
        end

        # Process rest parameter
        if parameters_node.rest && parameters_node.rest.name
          param_parts << "*#{parameters_node.rest.name}"
        end

        # Process post parameters
        parameters_node.posts.each do |post|
          param_parts << post.name.to_s
        end

        # Process block parameter
        if parameters_node.block
          param_parts << "&#{parameters_node.block.name}"
        end

        # Build insert text with tabstops
        insert_parts = []
        tab_index = 1

        param_parts.each do |param|
          if param.include?("=") || param.include?(":")
            # For parameters with default values, make them editable tabstops
            key, value = param.split(/[=:]/, 2)
            key = key.strip
            value = value.strip

            if param.include?(":")
              insert_parts << "${#{tab_index}:#{key}: ${#{tab_index+1}:#{value}}}"
              tab_index += 2
            else
              insert_parts << "${#{tab_index}:#{key} = #{value}}"
              tab_index += 1
            end
          elsif param.start_with?("**")
            # For keyword rest, make it optional
            insert_parts << "${#{tab_index}:**#{param[2..-1]}}"
            tab_index += 1
            tab_index += 1
          else
            # For regular parameters
            insert_parts << "${#{tab_index}:#{param}}"
            tab_index += 1
          end
        end

        # Return both a readable signature and insertable snippet
        return {
          signature: "(" + param_parts.join(", ") + ")",
          insert_text: "(" + insert_parts.join(", ") + ")$0",
          yard_doc: yard_doc
        }
      end

      def extract_node_value(node)
        case node
        when Prism::FalseNode
          "false"
        when Prism::TrueNode
          "true"
        when Prism::NilNode
          "nil"
        when Prism::IntegerNode
          node.value.to_s
        when Prism::FloatNode
          node.value.to_s
        when Prism::StringNode
          "\"#{node.unescaped}\""
        when Prism::SymbolNode
          ":#{node.value}"
        when Prism::ArrayNode
          "[#{node.elements.map { |e| extract_node_value(e) }.join(', ')}]"
        when Prism::HashNode
          "{#{node.elements.map { |e| "#{extract_node_value(e.key)} => #{extract_node_value(e.value)}" }.join(', ')}}"
        else
          # Default for more complex expressions
          node.location.slice
        end
      end
    end
  end
end
