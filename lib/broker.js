(function() {
  var cliDomainSocketPath, cliReloadPull, extensionPort, extensionServer, mp, probe, sio;

  probe = require('./probe');

  probe.enable();

  extensionPort = 35729;

  cliDomainSocketPath = 'ipc:///tmp/reload-browser-socket';

  sio = require('socket.io');

  extensionServer = sio.listen(extensionPort);

  extensionServer.sockets.on('connection', function(socket) {
    return probe('established browser connection');
  });

  mp = require('message-ports');

  mp.messageFormat = 'json';

  cliReloadPull = mp.pull(cliDomainSocketPath);

  cliReloadPull(function(data) {
    probe('received reload command', data);
    return extensionServer.sockets.emit('reload', data);
  });

  process.kill(process.id, 'SIGCHLD');

}).call(this);
