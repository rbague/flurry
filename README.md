# Flurry
[![Gem Version](https://badge.fury.io/rb/flurry.svg)](https://badge.fury.io/rb/flurry)
[![Build Status](https://travis-ci.org/rbague/flurry.svg?branch=master)](https://travis-ci.org/rbague/flurry)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

Flurry provides easy access to [Flurry Analytics Reporting API](https://developer.yahoo.com/flurry/docs/api/code/analyticsapi/)

Keep track of changes in [Changelog](https://github.com/rbague/flurry/blob/master/CHANGELOG.md)

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

To start using the gem provide an [api token] through `Flurry#configure`.
The results are displayed in UTC time zone and JSON format (as defined in Flurry), this can be changed by setting the respective configuration:
```ruby
Flurry.configure do |config|
  config.token = ENV['FLURRY_API_TOKEN']

  # Optional configuration
  config.time_zone = 'Europe/Madrid'
  config.format = :csv
  config.timeout = 30 # Timeout for opening connection and reading data
end
```

Once an API token has been set, requesting data is really easy
```ruby
require 'flurry'

# Gets todays the number of sessions from appUsage table grouped by day (default)
Flurry.from(:app_usage).select(:sessions).between(Date.today).fetch # HTTP::Response

# Same as above but grouping by hour
Flurry.from(:app_usage, :hour).select(:sessions).between(Date.today).fetch

# Use the sort method to sort the query results. Defaults to descending
Flurry.from(:app_usage).select(:sessions).sort(sessions: :asc).between(Date.today).fetch

# Gets the results from last week, also returning the app id, and the platform name (showing accepts an array as the key values)
Flurry.from(:app_usage).select(:sessions).showing(app: :id, platform: :name).between(Date.today - 7, Date.today).fetch

# To get only the metrics that match a condition: (gt, lt, eq)
Flurry.from(:app_usage).select(:sessions).having(sessions: { gt: 10, lt: 100 }).between(Date.today).fetch

# Change default configuration per request
Flurry.from(:app_usage).format(:csv).time_zone('Europe/Madrid')
```

## TODO

- [x] Sort by metrics (select)
- [ ] Filter by dimension (showing)
- [x] Havings
- [x] Response format
- [ ] Custom response class

## Contributing

1. Fork the project https://github.com/rbague/flurry/fork
2. Get an [api token] and set it to `FLURRY_TOKEN` environment variable
3. Run `bundle` and `bundle exec rake`
4. Make your feature or bug fix
5. Add tests for it. This is important so that it does not break in a future version.
6. Submit a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[api token]: https://developer.yahoo.com/flurry/docs/api/code/apptoken/
