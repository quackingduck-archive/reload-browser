(function() {
  var WSServer, connectedWebSockets, http, httpServer, port, qs, wss;

  port = 45729;

  connectedWebSockets = [];

  http = require('http');

  qs = require('querystring');

  httpServer = http.createServer(function(req, res) {
    var options, s, _i, _len;
    console.log("reload message received");
    options = JSON.stringify(qs.parse(req.url.split("?")[1]));
    for (_i = 0, _len = connectedWebSockets.length; _i < _len; _i++) {
      s = connectedWebSockets[_i];
      s.send(options);
    }
    return res.end();
  });

  WSServer = require('ws').Server;

  wss = new WSServer({
    server: httpServer
  });

  wss.on('connection', function(ws) {
    console.log("extension connected");
    connectedWebSockets.push(ws);
    return ws.on('close', function() {
      return connectedWebSockets.splice(connectedWebSockets.indexOf(ws), 1);
    });
  });

  httpServer.listen(port, function() {
    process.kill(process.id, 'SIGCHLD');
    return console.log("broker started");
  });

}).call(this);
