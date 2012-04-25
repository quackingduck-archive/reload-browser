# The broker pulls reload requests and publishes them to connected browser
# extensions.
#
# Pushing to a broker is done by sending it an http request (of any method)
# Subscribing to a broker is done by establishing a websocket connection

# todo: make same as current
port = 45729
connectedWebSockets = []

http = require 'http'
qs = require 'querystring'
httpServer = http.createServer (req, res) ->
  console.log "reload message received"
  console.log req.url, JSON.stringify(qs.parse(req.url.split("?")[1]))

  options = JSON.stringify(qs.parse(req.url.split("?")[1]))
  s.send options for s in connectedWebSockets
  res.end()

WSServer = require('ws').Server
wss = new WSServer server: httpServer
wss.on 'connection', (ws) ->
  # console.log "extension connected"

  connectedWebSockets.push ws
  ws.on 'close', ->
    connectedWebSockets.splice connectedWebSockets.indexOf(ws), 1

httpServer.listen port, ->
  process.kill process.id, 'SIGCHLD'
  console.log "broker started"
