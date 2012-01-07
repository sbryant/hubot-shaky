zmq = require('zmq')
util = require('util')
events = require('events')

class Client extends events.EventEmitter
  constructor: (@sub_addr, @dealer_addr, @filters) ->
    self = @

    @sub_sock = zmq.socket 'sub'
    @dealer_sock = zmq.socket 'dealer'

    @handlers = []
    @channels = []

    @filters = unless @filters then [":PRIVMSG", ":BOOT", ":INVITE", ":JOIN", ":PART"]
    @add_filter filter for filter in @filters

    @sub_sock.on 'error', @error
    @dealer_sock.on 'error', @error

    @sub_sock.on 'message', (headerMsg, dataMsg) ->
      header = headerMsg.toString().split(" ")
      data = JSON.parse(dataMsg.toString())
      switch header[0]
        when ":BOOT"
          for channel in self.channels
            self.request type: "join", channel: channel
          self.emit 'boot', data
        when ":PRIVMSG"
          self.emit 'message', data
        when ":JOIN"
          self.emit 'join', data
        when ":PART"
          self.emit 'part', data
        when ":INVITE"
          self.emit 'invite', data
        else
          console.log "Unhandled msg #{util.inspect data}"

    @dealer_sock.on 'message', (msg) ->
      console.log "got a reply! #{util.inspect msg}"
      data = JSON.parse msg.toString()
      if self.handlers.length isnt 0
        console.log "Invoking callback"
        self.handlers.pop()(data)

  connect: ->
    console.log "Connecting Sub to: #{@sub_addr}"
    @sub_sock.connect @sub_addr
    console.log "Connecting Dealer to: #{@dealer_addr}"
    @dealer_sock.connect @dealer_addr

  request: (msg, handler) ->
    console.log "Sending: #{JSON.stringify(msg)}"
    @dealer_sock.send(JSON.stringify(msg))
    if handler?
      @handlers.push handler

  add_filter: (filter) ->
    console.log "Subscribing to: #{filter}"
    @sub_sock.subscribe filter

  shutdown: ->
    @sub_sock.disconnect()
    @dealer_sock.disconnect()
    @handlers = []

  error: (e) ->
    console.log "Error: #{util.inspect e}"


exports.Client = Client