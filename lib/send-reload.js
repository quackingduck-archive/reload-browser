(function() {
  var http, qs;

  http = require('http');

  qs = require('querystring');

  module.exports = function(options, cb) {
    if (options == null) options = {};
    return http.request({
      port: 45729,
      path: '/?' + qs.stringify(options)
    }, cb).end();
  };

}).call(this);
