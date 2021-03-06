[![Build Status](https://travis-ci.org/gary/website_struct.svg?branch=master)](https://travis-ci.org/gary/website_struct)
[![Code Climate](https://codeclimate.com/github/gary/website_struct/badges/gpa.svg)](https://codeclimate.com/github/gary/website_struct) [![Test Coverage](https://codeclimate.com/github/gary/website_struct/badges/coverage.svg)](https://codeclimate.com/github/gary/website_struct/coverage)

# WebsiteStruct

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/website_struct`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Prerequisites

* [`postgresql`](http://www.postgresql.org/)

## Setup

Before you can use this gem, you must set up the database it uses
during executionn. To do so:

1) Configure your postgresql database to have a `website_struct` user:

    `$ createuser -d -P website_struct`

2) Instate the app's database configuration:

    `$ cp config/database.yml.example config/database.yml`

3) Add the password you entered in 1) to both adapter configurations
   in [`config/database.yml`](https://github.com/gary/website_struct/blob/master/config/database.yml.example)

4) Create the databases

    `$ bundle exec rake db:create`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'website_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install website_struct

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/website_struct. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

