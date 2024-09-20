module RailsDigger
  class Analyzer
    def initialize(directory)
      @directory = directory
    end

    def analyze
      ruby_files.each do |file|
        puts "Analyzing #{file}..."
        methods = extract_methods(file)
        puts "Methods found: #{methods.join(', ')}"
      end
    end

    private

    def ruby_files
      Dir.glob(File.join(@directory, '**', '*.rb'))
    end

    def extract_methods(file_path)
      buffer = Parser::Source::Buffer.new(file_path)
      buffer.source = File.read(file_path)
      parser = Parser::CurrentRuby.new
      ast = parser.parse(buffer)
      extract_methods_from_ast(ast)
    end

    def extract_methods_from_ast(node)
      return [] unless node.is_a?(Parser::AST::Node)

      methods = []
      if node.type == :def
        methods << node.children[0] # method name
      end

      node.children.each do |child|
        methods.concat(extract_methods_from_ast(child)) if child.is_a?(Parser::AST::Node)
      end

      methods
    end
  end
end
