Robot   = require('hubot').robot();
Adapter = require('hubot').adapter();
util = require('util');

Client  = require('../lib/clubot').Client;

class Shaky extends Adapter
  send: (user, strings...) ->
    for str in strings
      if not str?
        continue
      if user.room
        @bot.request("speak", target: user.room, msg:str)
      else
        @bot.request("speak", target: user.name, msg:str)

  reply: (user, strings...) ->
    for str in strings
      @send user, "#{user.name}: #{str}"

  run: ->
    self = @

    options =
      sub_addr:    process.env.HUBOT_SHAKY_SUB_ADDRESS
      channel:     process.env.HUBOT_SHAKY_CHANNEL
      dealer_addr: process.env.HUBOT_SHAKY_DEALER_ADDRESS

    bot = new Client options.sub_addr, options.dealer_addr, options.channel
    bot.connect()

    bot.on 'message', (type, target, from, data) ->
      user = self.userForName from

      unless user?
        id        = (new Date().getTime() / 1000).toString().replace('.','')
        user      = self.userForId id
        user.name = from

      unless target is data.self
        user.room = target

      self.receive new Robot.TextMessage(user, data.msg)

    @bot = bot

exports.use = (robot) ->
  new Shaky robot