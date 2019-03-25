# CHANGELOG

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
