require "crochet"

# Allow posts names to not begin with a date
STRICT_MATCH = Jekyll::Post::MATCHER
Jekyll::Post::MATCHER = /^(.+\/)*(\d+-\d+-\d+)?-?(.*)(\.[^.]+)$/

Crochet::Hook.new(Jekyll::Post) do
	before! :process do |name|
        mtime = File.mtime(File.join(@base, name))
        @mtime = mtime
        # If a post name doesn't begin with a date,
        # pretend the date is the last time the file
        # was modified.
		if not name =~ STRICT_MATCH
			split = File.split(name)
			name = File.join(split[0], "#{mtime.strftime("%Y-%m-%d")}-#{split[1]}")
		end
		name
	end
    # Make the mtime variable publicly available 
    after :initialize do
        self.data["mtime"] = @mtime
    end
end
