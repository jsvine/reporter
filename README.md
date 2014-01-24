# Reporter

__Reporter__ is a framework for publishing "literate data analysis." Crudely, it's a fancy HTML template with a toggle button for showing/hiding code and other inputs. Less crudely, it tries to resolve the tension, or bridge the gap, between __showing your work__ and __communicating with non-technical readers__. To learn more, see a [live example](http://notebooks.jsvine.com/) or [longer explanation](http://notebooks.jsvine.com/introducing-reporter). To get started, read on.

## Installation

__Reporter__ is built on the Ruby-based [Jekyll static-site generator](http://jekyllrb.com/) and accepts [iPython notebooks](http://ipython.org/notebook.html) as "posts." Support for other inputs, such as [knitr](http://yihui.name/knitr/) and [Literate Python](https://github.com/stdbrouw/python-literate) files, is planned.

To run __Reporter__, clone this repository onto your computer:

    git clone https://github.com/jsvine/reporter

And then install the required Ruby gems:

    gem install jekyll kramdown sanitize crochet

... or:

    bundle install

## Usage

Create a `_posts/` directory inside the directory where this README exists. Place the iPython notebooks (`.ipynb` files) you want inside that directory, just like you would do for Markdown files in a standard Jekyll project. (You can still put Markdown files in the directory; they'll get processed as usual.)

Rather than use [YAML front-matter](http://jekyllrb.com/docs/frontmatter/), __Reporter__ looks for posts variables in `.ipynb` files' `metadata` object, which is automatically present at the top of every such file. (`.ipynb` files are, in fact, just specalized JSON objects.) But __Reporter__ makes sure that you don't *need* to set any, that you can use iPython notebooks without any modifications. For instance, you don't need to a specific `date` variable for notebooks, either in the file path or the metadata, though you can if you'd like to. The [mtime plugin](_plugins/mtime.rb) sets posts' dates, where not specified, to the last time the file was modified.

Other than that, you run __Reporter__ just like you would any other Jekyll project: `jekyll build` to generate the site, `jekyll serve` to build the site and preview it on `localhost`.

You can change the site title, intro, and footer in [_config.yml](_config.yml).

## Future Plans

- Support for more input formats:
    - [knitr](http://yihui.name/knitr/)
    - [Literate Python](https://github.com/stdbrouw/python-literate)
    - Others?

- Support for versioning.

## License

__Reporter__ is licensed under the MIT License. See LICENSE.txt for more details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Reques
