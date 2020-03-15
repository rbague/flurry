# CHANGELOG

## v0.6.0
- Add response tests with webmock
- Return `Flurry::Response` in `#fetch` instead of `HTTP::Response`. That implies
  - `#body` return the parsed response (`Hash` for JSON, `Array` for CSV)
  - `#code` now returns an integer, and `#message` the response status text
  - You can still get the `HTTP::Response` object by calling `#raw`.

## v0.5.0
- Allow to chain calls to `showing`, `select`, `sort` and `having`

## v0.4.1
- Allow to pass the time range as a String in `Flurry#between` call
- Add HTTP timeout configuration in `Flurry#configure`, and as an argument to `Flurry#fetch`

## v0.4.0
- Add option to configure the response format through `Flurry.configuration.format`
- Allow to change the default settings per each request through `Flurry#format` and `Flurry#time_zone`

## v0.3.0
- Add the `Flurry#having` method to only get the results matching the given condition

## v0.2.0
- Add the `Flurry#sort` method to sort the query results by each metric (specified in `Flurry#select`)

## v0.1.0
- First version
