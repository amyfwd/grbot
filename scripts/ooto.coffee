# Description:
#   OOTO module to set an ooto msg and have people leave you msgs!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   ooto list - lists everyone who's ooto
#   ooto add <msg> - sets you as ooto
#   ooto edit <msg> - changes away msg
#   ooto back - sets you as back from ooto
#   ooto mymsgs - checks all your away msgs (if you're listed as ooto)
#   ooto msg <user> <msg> - sends msg to user if they're away
#   ooto help - shows this help

class UserOOTO
  constructor: (@user, @awayMsg) ->
    @messages = []

  setMessage: (msg) ->
    @awayMsg = msg

  getMessage: ->
    return @awayMsg

  addUserMessage: (user, msg) ->
    @messages.push { "user": user, "message": msg }

  getUserMessages: ->
    return @messages

module.exports = (robot) ->
  usersAway = {}

  printUserMessages = (user, msg) ->
    if usersAway[user].getUserMessages().length == 0
      msg.reply "You have not received any messages :("
    else
      for m in usersAway[user].getUserMessages()
        msg.reply m["user"] + " says: " + m["message"]

  robot.respond /ooto (\S+) (.*\S.*)/i, (msg) ->
    currentUser = msg.message.user.name.toLowerCase()
    awayMsg = msg.match[2]
    cmd = msg.match[1]
    switch cmd
      when "add"
        if usersAway[currentUser]
          msg.reply "You are already marked as OOTO. To change your ooto msg, use " +
                     "'ooto edit <new msg>'.  To see messages left to you, use " +
                     "'ooto mymsgs'.  To mark yourself as back from ooto, use 'ooto back'."
        else
          usersAway[currentUser] = new UserOOTO currentUser, awayMsg
          msg.reply "You are now marked as OOTO with the message: " + awayMsg
      when "edit"
        if usersAway[currentUser]
          usersAway[currentUser].setMessage awayMsg
          msg.reply "Your OOTO message has been updated: " + awayMsg
        else
          msg.reply "You are not OOTO! To add a new OOTO message, use 'ooto add <msg>'"

  robot.respond /ooto (\S+)/i, (msg) ->
    currentUser = msg.message.user.name.toLowerCase()
    cmd = msg.match[1]
    switch cmd
      when "list"
        msg.reply "All OOTO users and their away messages:"
        if Object.keys(usersAway).length == 0
          msg.reply "Nobody is OOTO!"
        else
          for user, ooto of usersAway
            msg.reply user + ": " + ooto.getMessage()
      when "back"
        if usersAway[currentUser]
          msg.reply "Welcome back! Here are all the messages you received while you were ooto:"
          printUserMessages currentUser, msg
          delete usersAway[currentUser]
          msg.reply "You have now been removed as OOTO."
        else
          msg.reply "You are not marked as OOTO! To add a new OOTO message, use 'ooto add <msg>'"
      when "mymsgs"
        if usersAway[currentUser]
          msg.reply "All messages received while you were ooto:"
          printUserMessages currentUser, msg
        else
          msg.reply "You are not marked as OOTO! To add a new OOTO message, use 'ooto add <msg>'"
      when "help"
        helpMsg = """
          ooto add <msg> - sets you as ooto
          ooto edit <msg> - changes your ooto msg
          ooto back - sets you as back from ooto
          ooto mymsgs - checks all your away msgs (if you're listed as ooto)
          ooto msg <user> <msg> - sends msg to user if they're away
          ooto list - lists everyone who's ooto
          ooto help - shows this help
          """
        msg.reply helpMsg

  robot.respond /ooto msg (\S+) (.*\S.*)/i, (msg) ->
    currentUser = msg.message.user.name.toLowerCase()
    user = msg.match[1].toLowerCase()
    message = msg.match[2]
    if usersAway[user]
      usersAway[user].addUserMessage currentUser, message
      msg.reply "Your message to " + user + " has been recorded: " + message
    else
      msg.reply "No user found who is OOTO with that name! To see a list of all OOTO users, " +
          "use 'ooto list'"