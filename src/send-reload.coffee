# Pushes a reload request to the broker.

http = require 'http'
qs = require 'querystring'

module.exports = (options = {}, cb) ->
  http.request( port: 45729, path: '/?' + qs.stringify(options), cb ).end()
