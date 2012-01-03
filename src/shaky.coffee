Robot   = require('hubot').robot();
Adapter = require('hubot').adapter();
util = require('util');

Client  = require('../lib/clubot').Client;

class Shaky extends Adapter
  send: (user, strings...) ->
    for str in strings
      if not str?
        continue
      @bot.request(type: "speak", target: user.room, msg: str)

  reply: (user, strings...) ->
    for str in strings
      @send user, "#{user.name}: #{str}"

  close: ->
    @bot.shutdown()

  run: ->
    console.log "Shaky booting..."
    self = @

    options =
      sub_addr:    process.env.HUBOT_SHAKY_SUB_ADDRESS
      filters:     process.env.HUBOT_SHAKY_FILTERS.split(",")
      dealer_addr: process.env.HUBOT_SHAKY_DEALER_ADDRESS

    bot = new Client options.sub_addr, options.dealer_addr, options.filters
    bot.connect()

    bot.request type: "nick", (data) ->
      console.log "Setting nick to #{data.nick}"
      self.robot.name = data.nick
      self.robot.alias = data.nick
      self.emit 'booted'

    bot.on 'boot', (data) ->
      console.log "Clubot boot event"
      self.robot.name data.nick

    bot.on 'invite', (data) ->
      console.log "Clubot invite event, #{data.where} #{data.by}"
      self.bot.request type: "join", channel: data.where

    bot.on 'join', (data) ->
      self.receive new Robot.EnterMessage(self.createOrFindUser(data.who, data.channel))
      console.log "Clobut join message"

    bot.on 'part', (data) ->
      self.receive new Robot.LeaveMessage(self.createOrFindUser(data.who, data.channel))
      console.log "Clobut part message"

    bot.on 'message', (data) ->
      console.log "Msg #{util.inspect data}"
      room = if data.target is data.self then data.from else data.target
      user = self.createOrFindUser data.from, room
      self.receive new Robot.TextMessage(user, data.msg)
    @bot = bot

  createOrFindUser: (name, channel) ->
    user = @userForId "#{name}-#{channel}"
    user.name = name
    user.room = channel
    user

exports.use = (robot) ->
  new Shaky robot