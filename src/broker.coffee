# A background process started by the invocation of the `reload-browser`
# executable.
#
# The process listens for http connections from the browser extension and push
# messages from subsequent invocations of `reload-browser`
#
# Reload messages are forwarded (by closing the http connection) to the
# browser extension.
#
# Right now this process dies ... when it's had enough. I'm not entirely clear
# why it doesn't run indefinitely. It should die probably time out after
# 10mins or so of idleness.

probe = require './probe'
# probe.enable()

# Config
extensionPort = 35729
cliDomainSocketPath = 'ipc:///tmp/reload-browser-socket'

# HTTP listener that accepts connections from the browser extension and keeps
# them open
conns = []
http = require 'http'
httpServer = http.createServer (req, res) ->
  probe 'established browser connection'
  res.writeHead 200, 'Content-Type': 'text/plain'
  conns.push res
httpServer.listen extensionPort

# The `reload-browser` sends push messages to this pull listener which are
# then forwarded to the open http connections.
mp = require 'message-ports'
mp.messageFormat = 'json'
cliReloadPull = mp.pull cliDomainSocketPath
cliReloadPull (data) ->
  probe 'received reload command', data
  for conn in conns
    conn.write JSON.stringify data
    conn.end()

# A signal to the process that launched this one (the `reload-browser`
# executable) that the listeners are up and running
process.kill process.id, 'SIGCHLD'
