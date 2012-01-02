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

    bot.on 'invite', (channel, inviter) ->
      console.log "Clubot invite event, #{channel} #{inviter}"
      self.bot.request type: "join", channel: channel

    bot.on 'join', (user, channel) ->
      self.receive new Robot.EnterMessage(self.createOrFindUser(user, channel))
      console.log "Clobut join message"

    bot.on 'part', (user, channel) ->
      self.receive new Robot.LeaveMessage(self.createOrFindUser(user, channel))
      console.log "Clobut part message"

    bot.on 'message', (type, target, from, data) ->
      console.log "Msg from #{from}, #{util.inspect data}"
      user = self.createOrFindUser from, target
      user.room = if target is "SELF" then from else target
      self.receive new Robot.TextMessage(user, data.msg)
    @bot = bot

  createOrFindUser: (name, channel) ->
    user = @userForId "#{name}-#{channel}"
    user.name = name
    user.room = channel
    user

exports.use = (robot) ->
  new Shaky robot