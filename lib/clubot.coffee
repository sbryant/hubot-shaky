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

    @add_filter filter for filter in @filters
    @add_filter filter for filter in [":BOOT", ":INVITE", ":JOIN", ":PART"] # standard filters

    @sub_sock.on 'message', (msg) ->
      [header, data] = msg.toString().split(" {")
      data = JSON.parse("{" + data)
      parts = header.split(" ")
      switch parts[0]
        when ":BOOT"
          for channel in self.channels
            self.request type: "join", channel: channel
          self.emit 'boot', data
        when ":PRIVMSG"
          [_, type, target, from] = parts
          self.emit 'message', data
        when ":JOIN"
          [_, user, channel] = parts
          self.emit 'join', data
        when ":PART"
          [_, user, channel] = parts
          self.emit 'part', data
        when ":INVITE"
          [_, channel, inviter] = parts
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
    @sub_sock.subscribe filter

  shutdown: ->
    @sub_sock.disconnect()
    @dealer_sock.disconnect()
    @handlers = []

exports.Client = Client