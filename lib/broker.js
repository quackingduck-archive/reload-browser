(function() {
  var WSServer, connectedWebSockets, fs, httpServer, https, port, qs, sslOptions, wss;

  port = 45729;

  connectedWebSockets = [];

  https = require('https');

  qs = require('querystring');

  fs = require('fs');

  sslOptions = {
    cert: fs.readFileSync(__dirname + '/../cert.pem'),
    key: fs.readFileSync(__dirname + '/../key.pem')
  };

  httpServer = https.createServer(sslOptions, function(req, res) {
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
