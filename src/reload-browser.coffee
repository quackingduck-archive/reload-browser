# Sends a reload message to the broker. We first check if the broker is
# running (i.e. it's listening on its port). If it isn't running we start
# it first.

net = require 'net'
sendReloadMsg = require './send-reload'
probe = if process.env.MPROBE? then require 'mprobe' else (->)

port = 45729

module.exports = (argv) ->

  options = {}
  options.css_only = yes if 'css' in argv

  c = net.connect port

  # Broker is already running
  c.on 'connect', ->
    c.destroy()
    sendReloadMsg options, ->
      console.error "reloaded"
      process.exit()

  # Broker needs to be started
  c.on 'error', ->
    cp = require 'child_process'
    child = cp.spawn 'sh', ['-c', brokerCommand()]
    # We should never see the broker exit, if this event occurs the broker
    # crashed
    child.on 'exit', process.exit

    process.on 'SIGCHLD', ->
      sendReloadMsg options, ->
        console.error 'reloaded (after starting broker)'
        process.exit()

# coffee command used during development
brokerCommand = ->
  cmd = if process.argv[0] is 'coffee'
    "coffee #{__dirname}/broker.coffee"
  else
    "node #{__dirname}/broker.js"
  # make sure the command has null file descriptors for its output streams
  cmd += ' > /dev/null 2> /dev/null'
  cmd
