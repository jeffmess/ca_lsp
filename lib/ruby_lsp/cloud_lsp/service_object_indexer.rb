# typed: true
require "yard"
require_relative "logger"

module RubyLsp
  module CloudLsp
    class ServiceObjectIndexer
      extend T::Sig
      include Logger

      attr_reader :docs, :service_classes

      sig { params(path: String).void }

      def initialize(path)
        @path = path
        @service_classes = {}
        @docs = {}
      end

      sig { returns(T.nilable([T::Hash[T.untyped, T.untyped], T::Hash[T.untyped, T.untyped]])) }

      def index
        log "Indexing Service Objects"
        log "------------------------"

        scan_service_objects
        parse_service_objects

        return [@service_classes, @docs]
      end

      private

      def scan_service_objects
        # Scan app/services directory
        app_services_pattern = "#{@path}/app/services/**/*.rb"
        Dir[app_services_pattern].each { |file| process_service_file(file) }

        # Scan packwerk packs
        packs_pattern = "#{@path}/packs/*/app/services/**/*.rb"
        Dir[packs_pattern].each { |file| process_service_file(file) }
      end

      def process_service_file(file_path)
        return unless File.exist?(file_path)

        file_content = File.read(file_path)
        return unless file_content.include?("include ServiceObject")

        result = Prism.parse(file_content)
        ast = result.value
        class_node = find_class_node(ast.statements.body)

        return unless class_node

        # Check if class includes ServiceObject
        includes_service_object = class_node.body.body.any? do |node|
          node.is_a?(Prism::CallNode) && 
          node.name == :include && 
          node.arguments&.arguments&.any? { |arg| extract_constant_name(arg) == "ServiceObject" }
        end

        return unless includes_service_object

        class_name = extract_full_class_name(class_node, file_path)
        @service_classes[class_name] = file_path

        log "Found ServiceObject: #{class_name} at #{file_path}"
      end

      def parse_service_objects
        @service_classes.each do |class_name, file_path|
          file_code = File.read(file_path)
          result = Prism.parse(file_code)
          _ = YARD.parse(file_path)
          ast = result.value
          class_node = find_class_node(ast.statements.body)

          next unless class_node

          initialize_node = class_node.body.body.find do |node|
            node.is_a?(Prism::DefNode) && node.name == :initialize
          end

          call_node = class_node.body.body.find do |node|
            node.is_a?(Prism::DefNode) && node.name == :call
          end

          # Extract YARD documentation
          class_docs = YARD::Registry.at(class_name)&.docstring || ""
          
          # Get initialize method documentation
          initialize_docs = if initialize_node
            method_docs = YARD::Registry.at("#{class_name}#initialize")&.tags || []
            build_method_documentation("initialize", method_docs, class_docs)
          else
            ""
          end

          # Get call method documentation  
          call_docs = if call_node
            method_docs = YARD::Registry.at("#{class_name}#call")&.tags || []
            build_method_documentation("call", method_docs, class_docs)
          else
            ""
          end

          # Combine documentation
          combined_docs = build_combined_documentation(class_name, class_docs, initialize_docs, call_docs, file_path)

          # Format parameters for completion (use initialize params for .call completion)
          formatted_params = if initialize_node
            format_parameters_for_completion(initialize_node.parameters, combined_docs)
          else
            { signature: "()", insert_text: "()", yard_doc: combined_docs }
          end

          @docs[class_name] = formatted_params.merge(path: file_path)
        end
      end

      def find_class_node(nodes)
        return nodes if nodes.is_a?(Prism::ClassNode)
        return nil if nodes.nil?

        nodes = [nodes] unless nodes.is_a?(Array)

        nodes.each do |node|
          case node
          when Prism::ClassNode
            return node
          when Prism::ModuleNode
            nested = find_class_node(node.body&.body)
            return nested if nested
          end
        end

        nil
      end

      def extract_constant_name(node)
        case node
        when Prism::ConstantReadNode
          node.name.to_s
        when Prism::ConstantPathNode
          build_constant_path(node)
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

      def extract_full_class_name(class_node, file_path)
        # Try to extract the full class name including namespace
        class_name = class_node.name.to_s

        # Try to infer namespace from file path
        relative_path = file_path.gsub(@path, "").gsub(/^\//, "")
        
        if relative_path.start_with?("app/services/")
          # Standard Rails services
          service_path = relative_path.gsub("app/services/", "").gsub(".rb", "")
          service_path.split("/").map { |part| camelize(part) }.join("::")
        elsif relative_path.match(/packs\/([^\/]+)\/app\/services\/(.+)\.rb/)
          # Packwerk services - we'll use just the class name for now
          # Could be enhanced to include pack namespace if needed
          service_path = $2
          service_path.split("/").map { |part| camelize(part) }.join("::")
        else
          class_name
        end
      end

      def camelize(term)
        term.to_s.gsub(/(?:^|_)([a-z\d])/) { $1.upcase }
      end

      def build_method_documentation(method_name, method_docs, class_docs)
        return "" if method_docs.empty?

        param_docs = method_docs.select { |tag| tag.tag_name == "param" }.map do |tag|
          "- **@param** #{tag.name} `#{tag.types&.first || 'Object'}` *#{tag.text}*"
        end.join("\n")

        example_docs = method_docs.select { |tag| tag.tag_name == "example" }.map do |tag|
          <<~HOVER
            ```ruby
            # #{tag.name}
            #{tag.text}
            ```
          HOVER
        end.join

        result = ""
        result += "## #{method_name.capitalize} Parameters\n#{param_docs}\n" unless param_docs.empty?
        result += "## Examples\n#{example_docs}" unless example_docs.empty?
        result
      end

      def build_combined_documentation(class_name, class_docs, initialize_docs, call_docs, file_path)
        <<~HOVER
          # #{class_name}
          ## Description
          #{class_docs}
          
          #{initialize_docs}
          
          #{call_docs}
          
          *#{file_path}*
        HOVER
      end

      def format_parameters_for_completion(parameters_node, yard_doc = "")
        return { signature: "()", insert_text: "()", yard_doc: yard_doc } if parameters_node.nil?
        
        # Start building parameter strings
        param_parts = []

        # Process required parameters
        parameters_node.requireds.each { |it| param_parts << it.name.to_s }

        # Process optional parameters
        parameters_node.optionals.each { |it| param_parts << "#{it.name} = #{extract_node_value(it.value)}" }

        # Process keyword parameters
        parameters_node.keywords.each do |kw|
          if kw.is_a?(Prism::OptionalKeywordParameterNode)
            default_value = extract_node_value(kw.value)
            param_parts << "#{kw.name}: #{default_value}"
          elsif kw.is_a?(Prism::RequiredKeywordParameterNode)
            param_parts << "#{kw.name}:"
          end
        end

        # Process keyword rest parameter
        param_parts << "**#{parameters_node.keyword_rest.name}" if parameters_node.keyword_rest

        # Process rest parameter
        param_parts << "*#{parameters_node.rest.name}" if parameters_node.rest && parameters_node.rest.name

        # Process post parameters
        parameters_node.posts.each { |it| param_parts << it.name.to_s }

        # Process block parameter
        param_parts << "&#{parameters_node.block.name}" if parameters_node.block

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
              insert_parts << "${#{tab_index}:#{key}: ${#{tab_index + 1}:#{value}}}"
              tab_index += 2
            else
              insert_parts << "${#{tab_index}:#{key} = #{value}}"
              tab_index += 1
            end
          elsif param.start_with?("**")
            # For keyword rest, make it optional
            insert_parts << "${#{tab_index}:**#{param[2..-1]}}"
            tab_index += 2
          else
            # For regular parameters
            insert_parts << "${#{tab_index}:#{param}}"
            tab_index += 1
          end
        end

        # Return both a readable signature and insertable snippet
        {
          signature: "(" + param_parts.join(", ") + ")",
          insert_text: "(" + insert_parts.join(", ") + ")$0",
          yard_doc: yard_doc
        }
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