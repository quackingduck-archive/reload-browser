# A background process started by the first call to `reload-browser` command.
# Listens for the reload messages created when `reload-browser` is invoked
# from the command line and connections from the browser extension.
#
# Reload messages are forwarded (via a websocket server) to the chrome
# extension
#
# Right now this process never dies. It should die probably time out after
# 10mins of idleness

probe = require './probe'
# probe.enable()

# Config
extensionPort = 35729
cliDomainSocketPath = 'ipc:///tmp/reload-browser-socket'

# The server the browser extension talks to
sio = require 'socket.io'
extensionServer = sio.listen extensionPort
extensionServer.sockets.on 'connection', (socket) ->
  probe 'established browser connection'

# The server the `reload-browser` command talks to
mp = require 'message-ports'
mp.messageFormat = 'json'
cliReloadPull = mp.pull cliDomainSocketPath
cliReloadPull (data) ->
  probe 'received reload command', data
  extensionServer.sockets.emit 'reload', data

# A signal to the process that launched this one (the `reload-browser`
# executable) that the listeners are up and running
process.kill process.id, 'SIGCHLD'
