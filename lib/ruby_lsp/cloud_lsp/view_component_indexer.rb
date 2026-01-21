# typed: true
require "yard"
require_relative "logger"

# Configure YARD to log to STDERR instead of STDOUT to avoid corrupting LSP protocol
YARD::Logger.instance.io = STDERR

module RubyLsp
  module CloudLsp
    class ViewComponentIndexer
      extend T::Sig
      include Logger

      attr_reader :docs, :deps, :class_to_helper_mapping, :component_classes

      sig { params(path: String).void }

      def initialize(path)
        @path = path
        @deps = {}
        @docs = {}
        @class_to_helper_mapping = {}
        @component_classes = {}
      end

      sig { returns(T.nilable([T::Hash[T.untyped, T.untyped], T::Hash[T.untyped, T.untyped]])) }

      def index
        log "Indexing View Components"
        log "------------------------"

        # Index helper-based components
        file_path = "#{@path}/app/helpers/cloud/view_helper.rb"
        if File.exist?(file_path)
          read_in_file(file_path)
          parse
          build_class_to_helper_mapping
        end

        # Index direct component class references
        index_component_classes

        return [@deps, @docs]
      end

      def read_in_file(file_path)
        file_content = File.read(file_path)
        if file_content =~ /HELPERS = \{(.*?)\}/m
          helpers_content = $1 # This will give you the part between { and }
          @deps = eval("{#{helpers_content}}") # Convert the extracted string back into a hash
        end
      end

      def parse
        @deps.each do |key, value|
          component_path = "#{@path}/app/components/#{transform_class_name(value)}"
          next unless File.exist?(component_path)

          file_code = File.read(component_path)
          result = Prism.parse(file_code)
          _ = YARD.parse(component_path)
          ast = result.value
          class_node = class_node(ast.statements.body)

          next unless class_node

          initialize_node = class_node.body.body.find do |node|
            node.is_a?(Prism::DefNode) && node.name == :initialize
          end

          next unless initialize_node

          # Perform yard documentation
          class_docs = YARD::Registry.at(value).docstring
          method_docs = YARD::Registry.at("#{value}#initialize").tags
          example_docs = method_docs.select { |tag| tag.tag_name == "example" }.map do |tag|
            <<~HOVER
              ```ruby
              # #{tag.name}
              #{tag.text}
              ```
            HOVER
          end
          example_docs = "## Examples\n#{example_docs.join}" if example_docs.any?

          param_docs = method_docs.select { |tag| tag.tag_name == "param" }.map do |tag|
            <<~HOVER
              - **@param** #{tag.name} `#{tag.types[0]}` *#{tag.text}* 
            HOVER
          end

          param_docs = if param_docs.any?
              <<~HOVER
                ## Params
                #{param_docs.join}
              HOVER
            else
              nil
            end

          docos = <<~HOVER
            # #{value}
            ## Docs: `#{class_docs}`
            ---
            #{param_docs}
            #{example_docs}
            *#{component_path}*
          HOVER

          # Get the line number of the initialize method (1-indexed for LSP)
          initialize_line = initialize_node.location.start_line
          
          @docs[key] = format_parameters_for_completion(initialize_node.parameters, docos).merge(
            path: component_path,
            initialize_line: initialize_line
          )
        end
      end

      def build_class_to_helper_mapping
        @deps.each do |helper_name, class_name|
          @class_to_helper_mapping[class_name] = helper_name
          log "Mapped #{class_name} -> #{helper_name}"
        end
      end

      def class_node(node)
        return node if node.is_a?(Prism::ClassNode)
        return false if node.nil?

        node = node.first if node.is_a? Array

        if node.is_a?(Prism::ModuleNode)
          return nil unless node.body&.body
          return class_node(node.body.body)
        elsif node.is_a?(Prism::ClassNode)
          return node
        end

        return false
      end

      def transform_class_name(class_name)
        class_name
          .gsub(/([A-Z])([A-Z])/, '\1_\2') # Insert underscore between consecutive uppercase letters (e.g., "CA" → "C_A")
          .gsub("::", "/") # Replace module separator with a slash
          .gsub(/([a-z\d])([A-Z])/, '\1_\2') # Convert CamelCase to snake_case
          .downcase + ".rb"                 # Convert to lowercase and append ".rb"
      end

      def format_parameters_for_completion(parameters_node, yard_doc = "")
        return { signature: "", text_input: "", yard: "" } if parameters_node.nil?
        
        begin
          # Start building parameter strings
          param_parts = []

          # Process required parameters
          parameters_node.requireds.each do |param|
            param_parts << (param.respond_to?(:name) ? param.name.to_s : param.to_s)
          end

        # Process optional parameters
        parameters_node.optionals.each do |param|
          name = param.respond_to?(:name) ? param.name : param.to_s
          value = extract_node_value(param.value) if param.respond_to?(:value)
          param_parts << "#{name} = #{value || 'nil'}"
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
        end

        # Process keyword rest parameter
        if parameters_node.keyword_rest&.respond_to?(:name)
          param_parts << "**#{parameters_node.keyword_rest.name}"
        end

        # Process rest parameter
        if parameters_node.rest&.respond_to?(:name) && parameters_node.rest.name
          param_parts << "*#{parameters_node.rest.name}"
        end

        # Process post parameters
        parameters_node.posts.each do |param|
          param_parts << (param.respond_to?(:name) ? param.name.to_s : param.to_s)
        end

        # Process block parameter
        if parameters_node.block&.respond_to?(:name)
          param_parts << "&#{parameters_node.block.name}"
        end
        
        # Process forwarding parameter (...) - only if supported
        if parameters_node.respond_to?(:forwarding) && parameters_node.forwarding
          param_parts << "..."
        end

        # Build insert text with tabstops
        insert_parts = []
        tab_index = 1

        param_parts.each do |param|
          if param == "..."
            # For forwarding parameter, just add it as-is
            insert_parts << "..."
          elsif param.include?("=") || param.include?(":")
            # For parameters with default values, make them editable tabstops
            key, value = param.split(/[=:]/, 2)
            key = key.strip
            value = value.strip

            if param.include?(":")
              insert_parts << "${#{tab_index}:#{key}: ${#{tab_index + 1}:#{value}}}"
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
                   yard_doc: yard_doc,
                 }
        rescue => e
          # Silently handle parameter processing errors to avoid log spam
          return { signature: "", insert_text: "", yard_doc: yard_doc }
        end
      end

      def index_component_classes
        component_paths = Dir.glob("#{@path}/app/components/**/*.rb") + 
                         Dir.glob("#{@path}/packs/*/app/components/**/*.rb")
        
        component_paths.each do |component_path|
          next unless File.exist?(component_path)
          
          class_name = extract_class_name_from_path(component_path)
          next if class_name.nil?
          
          # Skip if already indexed via helper mapping
          next if @class_to_helper_mapping.values.include?(class_name)
          
          index_component_class(component_path, class_name)
        end
      end

      def extract_class_name_from_path(component_path)
        # Convert file path to class name
        # e.g., "app/components/ui/date_component.rb" -> "UI::DateComponent"
        return nil unless component_path.end_with?('.rb')
        
        relative_path = component_path.gsub(@path + "/", "")
        
        # Remove app/components or packs/*/app/components prefix
        class_path = relative_path.gsub(/^(app\/components\/|packs\/[^\/]+\/app\/components\/)/, "")
        
        # Remove .rb extension
        class_path = class_path.gsub(/\.rb$/, "")
        
        # Skip if empty path after processing
        return nil if class_path.empty?
        
        # Convert to class name format
        parts = class_path.split("/")
        return nil if parts.empty?
        
        class_name = parts.map { |part| camelize(part) }.join("::")
        
        # Only return if it looks like a component class
        return class_name if class_name.end_with?("Component")
        
        nil
      end

      def index_component_class(component_path, class_name)
        return unless File.exist?(component_path)
        
        begin
          file_code = File.read(component_path)
          result = Prism.parse(file_code)
          _ = YARD.parse(component_path)
          ast = result.value
          return unless ast&.statements&.body
          class_node = class_node(ast.statements.body)
        rescue => e
          log "Error parsing #{component_path}: #{e.message}"
          return
        end
        
        return unless class_node
        return unless class_node.body&.body
        
        initialize_node = class_node.body.body.find do |node|
          node.is_a?(Prism::DefNode) && node.name == :initialize
        end
        
        return unless initialize_node
        
        # Perform yard documentation
        class_registry = YARD::Registry.at(class_name)
        class_docs = class_registry&.docstring || ""
        
        method_registry = YARD::Registry.at("#{class_name}#initialize")
        method_docs = method_registry&.tags || []
        
        example_docs = method_docs.select { |tag| tag.tag_name == "example" }.map do |tag|
          <<~HOVER
            ```ruby
            # #{tag.name}
            #{tag.text}
            ```
          HOVER
        end
        example_docs = "## Examples\n#{example_docs.join}" if example_docs.any?
        
        param_docs = method_docs.select { |tag| tag.tag_name == "param" }.map do |tag|
          types = tag.types&.first || "unknown"
          <<~HOVER
            - **@param** #{tag.name} `#{types}` *#{tag.text}* 
          HOVER
        end
        
        param_docs = if param_docs.any?
            <<~HOVER
              ## Params
              #{param_docs.join}
            HOVER
          else
            nil
          end
        
        docos = <<~HOVER
          # #{class_name}
          ## Docs: `#{class_docs}`
          ---
          #{param_docs}
          #{example_docs}
          *#{component_path}*
        HOVER
        
        # Get the line number of the initialize method (1-indexed for LSP)
        initialize_line = initialize_node.location.start_line
        
        @component_classes[class_name] = format_parameters_for_completion(initialize_node.parameters, docos).merge(
          path: component_path,
          initialize_line: initialize_line
        )
        log "Indexed component class: #{class_name}"
      end

      def camelize(snake_case_word)
        snake_case_word.split('_').map(&:capitalize).join
      end

      def extract_node_value(node)
        case node
        when Prism::FalseNode then "false"
        when Prism::TrueNode then "true"
        when Prism::NilNode then "nil"
        when Prism::IntegerNode then node.value.to_s
        when Prism::FloatNode then node.value.to_s
        when Prism::StringNode then "\"#{node.unescaped}\""
        when Prism::SymbolNode then ":#{node.value}"
        when Prism::ArrayNode then "[#{node.elements.map { |e| extract_node_value(e) }.join(", ")}]"
        when Prism::HashNode then "{#{node.elements.map { |e| "#{extract_node_value(e.key)} => #{extract_node_value(e.value)}" }.join(", ")}}"
        else
          # Default for more complex expressions
          node.location.slice
        end
      end
    end
  end
end
