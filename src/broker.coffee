# The broker pulls reload requests and publishes them to connected browsers.
#
# Pushing to a broker is done by sending it an http request (of any method)
# Subscribing to a broker is done by establishing a websocket connection

port = 45729
connectedWebSockets = []

https = require 'https'
qs = require 'querystring'
fs = require 'fs'

sslOptions =
  cert: fs.readFileSync __dirname + '/../cert.pem'
  key:  fs.readFileSync __dirname + '/../key.pem'

httpServer = https.createServer sslOptions, (req, res) ->
  args = JSON.stringify(qs.parse(req.url.split("?")[1]))
  console.error "reload message received, args: ", args
  s.send args for s in connectedWebSockets
  res.end()

WSServer = require('ws').Server
wss = new WSServer server: httpServer
wss.on 'connection', (ws) ->
  console.error "extension connected"

  connectedWebSockets.push ws
  ws.on 'close', ->
    connectedWebSockets.splice connectedWebSockets.indexOf(ws), 1

httpServer.listen port, ->
  process.kill process.id, 'SIGCHLD'
  console.error "broker started"
