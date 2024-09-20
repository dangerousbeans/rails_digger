# RailsDigger

[![GitHub](https://img.shields.io/badge/github-repo-blue)](https://github.com/dangerousbeans/rails_digger)

Welcome to **RailsDigger**! This gem is designed to analyze Rails applications, listing all defined methods and identifying unused code to help optimize and clean up your codebase.

## Installation

To install the gem and add it to your application's Gemfile, execute:

```bash
bundle add rails_digger
```

If Bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install rails_digger
```

## Usage

To use RailsDigger, simply run the analyzer on your Rails application directory:

```bash
rails_digger analyze /path/to/your/rails/app
```

This will output a report of all methods found and highlight any unused code.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [RailsDigger GitHub](https://github.com/dangerousbeans/rails_digger).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
