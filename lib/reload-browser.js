(function() {
  var brokerCommand, cliDomainSocketPath, net, probe, sendReloadMsg;

  net = require('net');

  probe = require('./probe');

  cliDomainSocketPath = '/tmp/reload-browser-socket';

  sendReloadMsg = require('./send-reload');

  this.reload = function() {
    var c;
    c = net.connect(cliDomainSocketPath);
    c.on('connect', function() {
      probe("broker is running");
      c.destroy();
      sendReloadMsg();
      console.error("reloaded");
      return process.exit();
    });
    return c.on('error', function() {
      var child, cp;
      probe("starting broker");
      cp = require('child_process');
      child = cp.spawn('sh', ['-c', brokerCommand()]);
      child.on('exit', function(err) {
        probe("broker crashed");
        return process.exit(err);
      });
      return process.on('SIGCHLD', function() {
        probe("received SIGCHLD from broker");
        sendReloadMsg();
        console.error("reloaded (after booting reload listener)");
        return process.exit();
      });
    });
  };

  brokerCommand = function() {
    var cmd;
    cmd = process.argv[0] === 'coffee' ? "coffee " + __dirname + "/broker.coffee" : "node " + __dirname + "/broker.js";
    return cmd += ' > /dev/null 2> /dev/null';
  };

}).call(this);
