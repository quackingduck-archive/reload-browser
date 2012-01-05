(function() {
  var cliDomainSocketPath, mp, probe, sendReloadMsgToBroker;

  probe = require('./probe');

  cliDomainSocketPath = '/tmp/reload-browser-socket';

  mp = require('message-ports');

  mp.messageFormat = 'json';

  sendReloadMsgToBroker = function() {
    var data, reloadPush;
    probe("connecting to broker");
    reloadPush = mp.push('ipc://' + cliDomainSocketPath);
    data = {
      path: process.cwd()
    };
    probe("sending data to broker", data);
    reloadPush(data);
    probe("closing connection to broker");
    return reloadPush.close();
  };

  module.exports = sendReloadMsgToBroker;

}).call(this);
