require "sanitize"
require "yaml"
require "crochet"
require "json"

# Intercept .ipynb files, and append their metadata as YAML. 
Crochet::Hook.new(File) do
	after! :read, :class do |result, path|
		if File.extname(path) == ".ipynb"
			STDERR.write "Processing #{path}\n"
			json = JSON.parse result
			meta = json["metadata"]
			meta["layout"] ||= "notebook"
			meta["title"] ||= meta["name"]
			YAML.dump(meta) + "---\n" + json.to_json
		else
			result
		end
	end
end

module Jekyll
    class IPYNBConverter < Converter
        safe false
        priority :normal
		def initialize(config={})
            _config = Reporter::DEFAULT_CONFIG.clone
			@config = _config.update(config || {})
		end
		def output_ext(ext)
			".html"
		end
		def matches(ext)
			ext =~ /ipynb/i
		end 
		def convert(content)
            data = JSON.parse(content)
            cells = data["worksheets"][0]["cells"].map do |c|
                convert_cell(c)
            end.flatten.compact
            notebook = Reporter::Notebook.new cells
            notebook.to_html(@config)
		end
        def join_if_array(obj, sep="")
            obj.kind_of?(Array) ? obj.join(sep) : obj
        end
        def convert_cell(c)
            if c["cell_type"] == "code"
                cells = convert_code_cell(c)
            elsif c["cell_type"] == "markdown"
                cells = convert_markdown_cell(c)
            elsif c["cell_type"] == "heading"
                cells = convert_heading_cell(c)
            else
                cells = nil
            end
            cells
        end
        def convert_code_cell(c)
            input = Reporter::CodeCell.new(join_if_array(c["input"]))
            outputs = c["outputs"].map do |o|
                inner = nil
                kind = Reporter::HTMLCell

                img_fmts = { "png" => "png", "jpeg" => "jpeg", "jpg" => "jpeg", "pdf" => "pdf" }
                img_fmt = img_fmts.keys.select { |k| o[k] }.first

                if img_fmt
                    inner = "<img src='data:image/#{img_fmts[img_fmt]};base64,#{o[img_fmt]}'/>"

                elsif o["html"]
                    dirty = join_if_array(o["html"])
                    inner = Sanitize.clean(dirty, Sanitize::Config::RELAXED)
                
                elsif o["svg"]
                    inner = join_if_array(o["svg"])

                elsif o["latex"]
                    inner = "<pre>LaTeX support TK.</pre>"
                    kind = Reporter::PlainTextCell

                elsif [ "stream", "pyout" ].include? o["output_type"] 
                    kind = Reporter::PlainTextCell
                    inner = "<pre>#{join_if_array(o["text"])}</pre>"

                elsif o["output_type"] == "pyerr"
                    kind = Reporter::ErrorCell
                    inner = "<pre>#{o["ename"]}: #{o["evalue"]}</pre>"
                end
                inner ? kind.new(inner, true) : nil
            end.flatten.compact
            [ input, outputs ].flatten
        end
        def convert_markdown_cell(c)
            Reporter::MarkdownCell.new(join_if_array(c["source"], "\n"), true)
        end
        def convert_heading_cell(c)
            level = c["level"]
            html = "<h#{level}>#{join_if_array(c["source"])}</h#{level}>"
            Reporter::HTMLCell.new(html, true)
        end
    end
end
