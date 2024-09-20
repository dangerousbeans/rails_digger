module RailsDigger
  class Analyzer
    def initialize(directory)
      @directory = directory
    end

    def analyze
      method_calls = count_method_calls
      routes_methods = extract_methods_from_routes
      puts "Methods expected from routes: #{routes_methods.join(', ')}"

      template_files.each do |file|
        puts "Analyzing template #{file}..."
        methods = extract_methods_from_template(file)
        puts "Methods found in template: #{methods.join(', ')}"
        methods.each { |method| method_calls[method] += 1 }
      end

      untestable_files = []
      results = ruby_files.map do |file|
        puts "Analyzing #{file}..."
        methods = extract_methods(file)
        puts "Methods found: #{methods.join(', ')}"
        sorted_methods = methods.sort_by { |method| -method_calls[method] }
        untestable_files << file if methods.empty?
        { file: file, methods: sorted_methods, calls: method_calls }
      end

      unless untestable_files.empty?
        puts "Untestable files (no methods found): #{untestable_files.join(', ')}"
      end

      report_path = File.expand_path('analysis_report.html', Dir.pwd)
      results.sort_by! { |result| -result[:methods].sum { |method| method_calls[method] } }
      unused_methods = find_unused_methods(results, method_calls)
      generate_html_report(results, report_path, untestable_files, unused_methods)
      puts "HTML report generated at #{report_path}"
    end

    private

    def template_files
      Dir.glob(File.join(@directory, '**', '*.html.erb'))
    end

    def extract_methods_from_template(file_path)
      methods = []
      File.readlines(file_path).each do |line|
        # Regex to match method calls in templates
        line.scan(/<%=\s*(\w+)\s*%>/).each do |match|
          methods << match.first
        end
      end
      methods
    end

    def routes_file
      File.join(@directory, 'config', 'routes.rb')
    end

    def extract_methods_from_routes
      methods = []
      if File.exist?(routes_file)
        File.readlines(routes_file).each do |line|
          # Regex to match controller#action in routes
          line.scan(/(\w+)#(\w+)/).each do |match|
            methods << match.last
          end
        end
      end
      methods
    end

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
      elsif node.type == :defs
        methods << node.children[1] # class method name
      elsif node.type == :send && node.children[1] == :define_method
        methods << node.children[2] # dynamic method name
      end

      node.children.each do |child|
        methods.concat(extract_methods_from_ast(child)) if child.is_a?(Parser::AST::Node)
      end

      methods
    end

    def count_method_calls
      method_calls = Hash.new(0)
      ruby_files.each do |file|
        buffer = Parser::Source::Buffer.new(file)
        buffer.source = File.read(file)
        parser = Parser::CurrentRuby.new
        ast = parser.parse(buffer)
        count_calls_in_ast(ast, method_calls)
      end
      method_calls
    end

    def count_calls_in_ast(node, method_calls)
      return unless node.is_a?(Parser::AST::Node)

      if node.type == :send
        method_name = node.children[1]
        method_calls[method_name] += 1
      end

      node.children.each do |child|
        count_calls_in_ast(child, method_calls) if child.is_a?(Parser::AST::Node)
      end
    end

    def find_unused_methods(results, method_calls)
      unused_methods = []
      results.each do |result|
        result[:methods].each do |method|
          if method_calls[method].zero?
            method_lines = count_method_lines(result[:file], method)
            unused_methods << { file: result[:file], method: method, lines: method_lines }
          end
        end
      end
      unused_methods.sort_by { |method_info| -method_info[:lines] }
    end

    def count_method_lines(file_path, method_name)
      lines = File.readlines(file_path)
      method_start = lines.index { |line| line.include?("def #{method_name}") }
      return 0 unless method_start

      method_end = lines[method_start..-1].index { |line| line.strip == 'end' }
      method_end ? method_end + 1 : 0
    end

    def generate_html_report(results, report_path, untestable_files, unused_methods)
      File.open(report_path, "w") do |file|
        file.puts "<html><head><title>Analysis Report</title></head><body>"
        file.puts "<h1>Analysis Report</h1>"
        file.puts "<h2>Untestable Files</h2>"
        file.puts "<ul>"
        untestable_files.each do |untestable_file|
          file.puts "<li>#{untestable_file}</li>"
        end
        file.puts "</ul>"

        file.puts "<h2>Testable Files</h2>"
        results.each do |result|
          file.puts "<h3>File: #{result[:file]}</h3>"
          file.puts "<ul>"
          result[:methods].each do |method|
            file.puts "<li>#{method} (called #{result[:calls][method]} times)</li>"
          end
          file.puts "</ul>"
        end
        file.puts "<h2>Unused Methods</h2>"
        file.puts "<ul>"
        unused_methods.each do |method_info|
          file.puts "<li>#{method_info[:method]} in #{method_info[:file]} (#{method_info[:lines]} lines)</li>"
        end
        file.puts "</ul>"

        file.puts "</body></html>"
      end
    end
  end
end
