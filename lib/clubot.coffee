zmq = require('zmq')
util = require('util')
events = require('events')

class Client extends events.EventEmitter
  constructor: (@sub_addr, @dealer_addr, @channel) ->
    @sub_sock = zmq.socket 'sub'

    @sub_sock.subscribe @sub_channel(@channel)

    @dealer_sock = zmq.socket 'dealer'

    self = @

    @sub_sock.on 'message', (msg) ->
      [header, data] = msg.toString().split(" {")
      data = JSON.parse("{" + data)
      [head, type, target, from] = header.split(" ")
      self.emit 'message', type, target, from, data

    @dealer_sock.on 'message', (msg) ->
      data = JSON.parse msg.toString()

      self.emit 'reply', data

  connect: ->
    console.log "Connecting Sub to: #{@sub_addr}"
    @sub_sock.connect @sub_addr
    console.log "Connecting Dealer to: #{@dealer_addr}"
    @dealer_sock.connect @dealer_addr

  request: (type, args) ->
    args['type'] = type
    console.log "Sending: #{JSON.stringify(args)}"
    @dealer_sock.send(JSON.stringify(args))

  sub_channel: (channel) ->
    if channel and channel.length > 0
      ":PRIVMSG #{channel}"
    else
      ":PRIVMSG"

exports.Client = Client