Robot   = require('hubot').robot();
Adapter = require('hubot').adapter();
util = require('util');

Client  = require('../lib/clubot').Client;

class Shaky extends Adapter
  send: (user, strings...) ->
    target = if user.room? then user.room else user.name
    for str in strings
      if not str?
        continue
      console.log("speaking, #{str}")
      @bot.request(type: "speak", target: target, msg: str)

  reply: (user, strings...) ->
    for str in strings
      @send user, "#{user.name}: #{str}"

  run: ->
    self = @

    options =
      sub_addr:    process.env.HUBOT_SHAKY_SUB_ADDRESS
      filters:     process.env.HUBOT_SHAKY_FILTERS.split(",")
      dealer_addr: process.env.HUBOT_SHAKY_DEALER_ADDRESS

    bot = new Client options.sub_addr, options.dealer_addr, options.filters
    bot.connect()

    bot.request type: "nick", (data) ->
      console.log "Setting nick to #{data.nick}"
      self.name = data.nick

    bot.on 'message', (type, target, from, data) ->
      console.log "Msg from #{from}, #{data.toString()}"
      user = self.userForName from
      console.log "User #{util.inspect user}"
      unless user?
        id        = from
        user      = self.userForId id
        user.name = from

      if target is data.self
        user.room = from
      else
        user.room = target

      self.receive new Robot.TextMessage(user, data.msg)
    @bot = bot

exports.use = (robot) ->
  new Shaky robot