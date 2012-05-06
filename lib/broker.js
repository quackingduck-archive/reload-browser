(function() {
  var WSServer, connectedWebSockets, http, httpServer, port, qs, wss;

  port = 45729;

  connectedWebSockets = [];

  http = require('http');

  qs = require('querystring');

  httpServer = http.createServer(function(req, res) {
    var args, s, _i, _len;
    args = JSON.stringify(qs.parse(req.url.split("?")[1]));
    console.error("reload message received, args: ", args);
    for (_i = 0, _len = connectedWebSockets.length; _i < _len; _i++) {
      s = connectedWebSockets[_i];
      s.send(args);
    }
    return res.end();
  });

  WSServer = require('ws').Server;

  wss = new WSServer({
    server: httpServer
  });

  wss.on('connection', function(ws) {
    console.error("extension connected");
    connectedWebSockets.push(ws);
    return ws.on('close', function() {
      return connectedWebSockets.splice(connectedWebSockets.indexOf(ws), 1);
    });
  });

  httpServer.listen(port, function() {
    process.kill(process.id, 'SIGCHLD');
    return console.error("broker started");
  });

}).call(this);
