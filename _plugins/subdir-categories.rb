require "crochet"

Crochet::Hook.new(Jekyll::Post) do
	after :initialize do |post, site, source, dir, name|
        subdirs = name.split("/")[0...-1]
        new_categories = (self.categories + subdirs).compact.uniq
		self.categories = new_categories
	end
end
