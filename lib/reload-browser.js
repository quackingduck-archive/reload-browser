(function() {
  var brokerCommand, net, port, probe, sendReloadMsg,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  net = require('net');

  sendReloadMsg = require('./send-reload');

  probe = process.env.MPROBE != null ? require('mprobe') : (function() {});

  port = 45729;

  module.exports = function(argv) {
    var c, options;
    options = {};
    if (__indexOf.call(argv, 'css') >= 0) options.css_only = true;
    c = net.connect(port);
    c.on('connect', function() {
      c.destroy();
      return sendReloadMsg(options, function() {
        console.error("reloaded");
        return process.exit();
      });
    });
    return c.on('error', function() {
      var child, cp;
      cp = require('child_process');
      child = cp.spawn('sh', ['-c', brokerCommand()]);
      child.on('exit', process.exit);
      return process.on('SIGCHLD', function() {
        return sendReloadMsg(options, function() {
          console.error('reloaded (after starting broker)');
          return process.exit();
        });
      });
    });
  };

  brokerCommand = function() {
    var cmd;
    cmd = process.argv[0] === 'coffee' ? "coffee " + __dirname + "/broker.coffee" : "node " + __dirname + "/broker.js";
    cmd += ' > /dev/null 2> /dev/null';
    return cmd;
  };

}).call(this);
