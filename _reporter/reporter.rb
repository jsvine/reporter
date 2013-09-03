require "kramdown"
require "pygments"

module Reporter
    DEFAULT_CONFIG = {
        :pygments => true, # Run pygments on code snippets
        :pygments_lexer => "python", 
        :css_prefix => "reporter-"
    }

    class Notebook
        def initialize(cells)
            @cells = cells
        end
        def to_html(cell_opts = {}, skip_classes = [])
            cell_html = @cells.map do |c|
                c.instance_of_any?(skip_classes) ? nil : c.to_html(cell_opts)
            end.compact.join("\n")
            return """<div class='#{cell_opts[:css_prefix]}notebook'>\n#{cell_html}\n</div>"
        end
    end
    class Cell
        def initialize(text, is_output = false)
            @text = text
            @is_output = is_output
            @css_classes= [ 
                "cell", 
                is_output ? "output" : "input"
            ]
        end
        def instance_of_any?(classes)
            matches = classes.map do |c|
                self.instance_of? c
            end.compact.length > 0
        end
        def linecount
            @text.split("\n").length
        end
        def inner(opts)
            # Subclasses should override.
        end
		def to_html(opts)
			inner_html = inner(opts)
			class_str = @css_classes.map {|x| opts[:css_prefix] + x }.join(" ")
			"<div class='#{class_str}' data-linecount='#{linecount}'>#{inner_html}</div>"
		end
    end
    class PlainTextCell < Cell
        def inner(opts)
            @css_classes << "text-cell"
            @text
        end
    end
    class ErrorCell < Cell
        def inner(opts)
            @css_classes << "stderr"
            @text
        end
    end
    class CodeCell < Cell
        def inner(opts)
            @css_classes << "code-cell"
			if opts[:pygments]
				Pygments.highlight @text, :lexer => opts[:pygments_lexer]
            else
                @text
			end
        end
    end
    class MarkdownCell < Cell
        def inner(opts)
            @css_classes << "markdown-cell"
            Kramdown::Document.new(@text, :auto_ids => false, :smart_quotes => "39,39,quot,quot").to_html.strip
        end
    end
    class HTMLCell < Cell
        def inner(opts)
            @css_classes << "html-cell"
            @text
        end
    end
end

# Load converters
here = File.expand_path(File.dirname(__FILE__))
converters = Dir[File.join(here, "converters", "*.rb")]
converters.each do |f|
    require f
end
