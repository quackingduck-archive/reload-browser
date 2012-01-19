(function() {
  var cliDomainSocketPath, cliReloadPull, conns, extensionPort, http, httpServer, mp, probe;

  probe = require('./probe');

  extensionPort = 35729;

  cliDomainSocketPath = 'ipc:///tmp/reload-browser-socket';

  conns = [];

  http = require('http');

  httpServer = http.createServer(function(req, res) {
    probe('established browser connection');
    res.writeHead(200, {
      'Content-Type': 'text/plain'
    });
    return conns.push(res);
  });

  httpServer.listen(extensionPort);

  mp = require('message-ports');

  mp.messageFormat = 'json';

  cliReloadPull = mp.pull(cliDomainSocketPath);

  cliReloadPull(function(data) {
    var conn, _i, _len, _results;
    probe('received reload command', data);
    _results = [];
    for (_i = 0, _len = conns.length; _i < _len; _i++) {
      conn = conns[_i];
      conn.write(JSON.stringify(data));
      _results.push(conn.end());
    }
    return _results;
  });

  process.kill(process.id, 'SIGCHLD');

}).call(this);
