# Opal-Ferro

[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://rubydoc.org/gems/opal-ferro)
[![Gem Version](https://img.shields.io/badge/gem%20version-0.10.2-blue.svg)](https://github.com/easydatawarehousing/opal-ferro/releases)
[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

Ferro is a small Ruby library on top of [Opal](http://opalrb.com/)
that enables an object-oriented programming style for creating code
that runs in the webbrowser.
No more distractions like HTML and searching for DOM elements,
just beautiful and simple Ruby code. Front-End-Ruby-ROcks!

## Installation
Add this line to your application's Gemfile:

``` ruby
gem 'opal-ferro'
```

And then execute:

    bundle

Or install it yourself:

    gem install opal-ferro

## Usage
Please see the [Ferro website](https://easydatawarehousing.github.io/ferro/)
for background information and examples.

## Versioning
Opal-Ferro follows the versioning scheme of [Opal](https://github.com/opal/opal).
The first two parts of the version number of Ferro imply compatibility
with the Opal version with that same number.
So Ferro 0.10.x should be compatible with and dependant on Opal 0.10.x.

## Roadmap
Please see the development roadmap
[here](https://github.com/easydatawarehousing/opal-ferro/wiki/Development-roadmap)
for the current wishlist of features to be added to Ferro.

## Development
To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`
and then run `bundle exec rake release`, which will create a git tag for
the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at
https://github.com/easydatawarehousing/opal-ferro.
This project is intended to be a safe, welcoming space for collaboration
and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Documentation
Yard is used to generate documentation. In development start yard using:

    yard server -r

Use this to list all undocumented items:

    yard stats --list-undoc

To generate documentation for publication, cd into project root and use:

    yardoc

## License
The gem is available as open source under the terms of the MIT License.
See LICENSE.txt
