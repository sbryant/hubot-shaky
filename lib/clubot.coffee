zmq = require('zmq')
util = require('util')
events = require('events')

class Client extends events.EventEmitter
  constructor: (@sub_addr, @dealer_addr, @filters) ->
    self = @

    @sub_sock = zmq.socket 'sub'
    @dealer_sock = zmq.socket 'dealer'

    @handlers = []

    @add_filter filter for filter in @filters

    @sub_sock.on 'message', (msg) ->
      [header, data] = msg.toString().split(" {")
      data = JSON.parse("{" + data)
      [head, type, target, from] = header.split(" ")
      self.emit 'message', type, target, from, data

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

exports.Client = Client