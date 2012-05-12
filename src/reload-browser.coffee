###

In order to get the browser to refresh the current page we have to get a
message to it. Browsers aren't generally designed to sit around waiting for
messages from random processes but they _are_ designed to make http
connections to servers.

The way this works is that the browser extension is always trying to establish
a websocket connection to a local webserver on port 45729. We call this the
"broker" server. If the extension can establish the connection it sleeps for
a second then tries again.

This module implements starting the broker (`.startBroker`) and sending it the
reload message (`sendReloadMsg`). The `reloadBrowser` method first tries to
connect to the broker, if it's up it sends it the reload message, if it isn't
then it starts it first then sends it the reload message.

###

module.exports = rb = -> rb.reloadBrowser.apply rb, arguments

rb.port = 45729

rb.cli = (argv) ->
  args = rb.parseArgs argv
  if args.install_extension
    console.log "installing #{args.install_extension} extension"
    rb.installExtension args.install_extension
    process.exit()

  @reloadBrowser args, (err, brokerStarted) ->
    throw err if err?
    console.error 'reloaded' + (if brokerStarted then ' (after starting broker)' else '')
    process.exit()

rb.reloadBrowser = (args = {}, callback) ->
  callback ?= (->)
  @attemptConnectionToBroker
    success: =>
      @sendReloadMsg args, (err) -> callback err, brokerStarted=no
    failure: =>
      @startBroker (err) =>
        return callback(err) if err?
        # wait one second to esure browser connects
        setTimeout =>
          @sendReloadMsg args, (err) -> callback err, brokerStarted=yes
        , 1000

rb.sendReloadMsg = (args = {}, callback) ->
  req = require('http').request
    port: @port
    path: '/?' + require('querystring').stringify(args)
  req.on 'response', -> callback()
  req.on 'error', callback
  req.end()

rb.attemptConnectionToBroker = (args = {}) ->
  conn = require('net').connect @port
  conn.on 'connect', -> conn.destroy(); args.success()
  conn.on 'error', args.failure

# starting the broker in a subshell and setting null file descriptors for
# output streams seems to detach the child process from its parent well enough

rb.startBroker = (callback) ->
  child = require('child_process').spawn 'sh', ['-c', @brokerCommand]
  # We should never see the broker exit, if we catch this event then it means
  # the broker crashed
  child.on 'exit', -> callback err="failed to start broker"
  # Broker fires SIGCHLD when it's ready to receive connections
  process.once 'SIGCHLD', -> callback()

rb.brokerCommand = "node #{__dirname}/broker.js > /dev/null 2> /dev/null"

# just installs the chrome extension atm
rb.installExtension = (browser) ->
  exec = require('child_process').exec
  switch browser
    when 'chrome' then exec "open #{__dirname}/../browser-extensions/build/*.crx"

rb.parseArgs = (argv) ->
  args = {}
  if '--install-chrome-extension' in argv
    args.install_extension = 'chrome'
  if 'css' in argv
    args.css_only = yes
  args
