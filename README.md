# Flurry
[![Gem Version](https://badge.fury.io/rb/flurry.svg)](https://badge.fury.io/rb/flurry)
[![Build Status](https://travis-ci.org/rbague/flurry.svg?branch=master)](https://travis-ci.org/rbague/flurry)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

Flurry provides easy access to [Flurry Analytics Reporting API](https://developer.yahoo.com/flurry/docs/api/code/analyticsapi/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flurry'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flurry

## Usage

To start using the gem provide an [api token](https://developer.yahoo.com/flurry/docs/api/code/apptoken/) through `Flurry#configure`.
The results are displayed in UTC time zone (as defined in Flurry), this can be changed by setting the time_zone param:
```ruby
Flurry.configure do |config|
  config.token = ENV['FLURRY_API_TOKEN']
  config.time_zone = 'Europe/Madrid'
end
```

Once an API token has been set, requesting data is really easy
```ruby
require 'flurry'

# Gets todays the number of sessions from appUsage table grouped by day (default)
Flurry.from(:app_usage).select(:sessions).between(Date.today).fetch # HTTP::Response

# Same as above but grouping by hour
Flurry.from(:app_usage, :hour).select(:sessions).between(Date.today).fetch # HTTP::Response

# Gets the results from last week, also returning the app id, and the platform name (showing accepts an array as the key values)
Flurry.from(:app_usage).select(:sessions).showing(app: :id, platform: :name).between(Date.today - 7, Date.today).fetch
```

## TODO

- [ ] Sort by metrics (select)
- [ ] Filter by dimension (showing)
- [ ] Havings
- [ ] Response format

## Contributing

1. Fork the project https://github.com/rbague/flurry/fork
2. Run `bundle` and `bundle exec rake`
3. Make your feature or bug fix
4. Add tests for it. This is important so that it does not break in a future version unintentionally.
5. Submit a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
