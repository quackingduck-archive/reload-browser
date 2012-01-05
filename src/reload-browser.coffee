net = require 'net'

probe = require './probe'
probe.enable()

# config
cliDomainSocketPath = '/tmp/reload-browser-socket'

sendReloadMsg = require './send-reload'

# Sends a reload message to the broker. We first check if the broker is
# running (i.e. it's listening on its socket). If it isn't running we start
# it first.
@reload = ->
  c = net.connect cliDomainSocketPath

  # Broker is already running
  c.on 'connect', ->
    probe "connected to broker"
    c.destroy()
    sendReloadMsg()
    process.exit()

  # Broker needs to be started
  c.on 'error', ->
    probe "starting broker"
    cp = require 'child_process'

    child = cp.spawn 'sh', ['-c', brokerCommand()], setsid: yes

    # We should never see the broker exit, if this event occurs the broker
    # crashed
    child.on 'exit', (err) ->
      probe "broker crashed"
      process.exit err

    # Broker sends SIGCHLD when it's up and running
    process.on 'SIGCHLD', ->
      probe "received SIGCHLD from broker"
      sendReloadMsg()
      process.exit()

# coffee command used during development
brokerCommand = ->
  cmd = if process.argv[0] is 'coffee'
    "coffee #{__dirname}/broker.coffee"
  else
    "node #{__dirname}/broker.js"
  # make sure the command has null file descriptors for its output streams
  cmd += '> /dev/null 2> /dev/null'

