probe = require './probe'
# probe.enable()

# config
cliDomainSocketPath = '/tmp/reload-browser-socket'

mp = require 'message-ports'
mp.messageFormat = 'json'

sendReloadMsgToBroker = ->
  probe "connecting to broker"
  reloadPush = mp.push 'ipc://' + cliDomainSocketPath
  data = path: process.cwd()
  probe "sending data to broker", data
  reloadPush data
  probe "closing connection to broker"
  reloadPush.close()

module.exports = sendReloadMsgToBroker
