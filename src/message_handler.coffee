u = require 'util'

class exports.MessageHandler
  constructor: (@web_join_callback) ->
  
  log: (message) -> u.log "HANDLER> #{message}"
  
  login: (data) =>
    @log "Login successful. Player ID: #{data.entity_id}"
      
  error: (data) =>
    @log("Server Error: #{data.message}")
  