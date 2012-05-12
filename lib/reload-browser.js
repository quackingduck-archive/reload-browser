
/*

In order to get the browser to refresh the current page we have to get a
message to it. Browsers aren't generally designed to sit around waiting for
messages from random processes but they _are_ designed to make http
connections to servers.

The way this works is that the browser extension is always trying to establish
a websocket connection to a local webserver on port 45729. We call this the
"broker" server. If the extension can establish the connection it sleeps for
a second then tries again.

This module implements starting the broker (`.startBroker`) and sending it the
reload message (`sendReloadMsg`). The `reloadBrowser` method first tries to
connect to the broker, if it's up it sends it the reload message, if it isn't
then it starts it first then sends it the reload message.
*/

(function() {
  var rb,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  module.exports = rb = function() {
    return rb.reloadBrowser.apply(rb, arguments);
  };

  rb.port = 45729;

  rb.cli = function(argv) {
    var args;
    args = rb.parseArgs(argv);
    if (args.install_extension) {
      console.log("installing " + args.install_extension + " extension");
      rb.installExtension(args.install_extension);
      process.exit();
    }
    return this.reloadBrowser(args, function(err, brokerStarted) {
      if (err != null) throw err;
      console.error('reloaded' + (brokerStarted ? ' (after starting broker)' : ''));
      return process.exit();
    });
  };

  rb.reloadBrowser = function(args, callback) {
    var _this = this;
    if (args == null) args = {};
    if (callback == null) callback = (function() {});
    return this.attemptConnectionToBroker({
      success: function() {
        return _this.sendReloadMsg(args, function(err) {
          var brokerStarted;
          return callback(err, brokerStarted = false);
        });
      },
      failure: function() {
        return _this.startBroker(function(err) {
          if (err != null) return callback(err);
          return setTimeout(function() {
            return _this.sendReloadMsg(args, function(err) {
              var brokerStarted;
              return callback(err, brokerStarted = true);
            });
          }, 1000);
        });
      }
    });
  };

  rb.sendReloadMsg = function(args, callback) {
    var req;
    if (args == null) args = {};
    req = require('http').request({
      port: this.port,
      path: '/?' + require('querystring').stringify(args)
    });
    req.on('response', function() {
      return callback();
    });
    req.on('error', callback);
    return req.end();
  };

  rb.attemptConnectionToBroker = function(args) {
    var conn;
    if (args == null) args = {};
    conn = require('net').connect(this.port);
    conn.on('connect', function() {
      conn.destroy();
      return args.success();
    });
    return conn.on('error', args.failure);
  };

  rb.startBroker = function(callback) {
    var child;
    child = require('child_process').spawn('sh', ['-c', this.brokerCommand]);
    child.on('exit', function() {
      var err;
      return callback(err = "failed to start broker");
    });
    return process.once('SIGCHLD', function() {
      return callback();
    });
  };

  rb.brokerCommand = "node " + __dirname + "/broker.js > /dev/null 2> /dev/null";

  rb.installExtension = function(browser) {
    var exec;
    exec = require('child_process').exec;
    switch (browser) {
      case 'chrome':
        return exec("open " + __dirname + "/../browser-extensions/build/*.crx");
    }
  };

  rb.parseArgs = function(argv) {
    var args;
    args = {};
    if (__indexOf.call(argv, '--install-chrome-extension') >= 0) {
      args.install_extension = 'chrome';
    }
    if (__indexOf.call(argv, 'css') >= 0) args.css_only = true;
    return args;
  };

}).call(this);
