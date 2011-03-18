u          = require 'util'

web_client = require './web_client'
Handshaker = require('./handshaker').Handshaker

[username, password] = ['whatupdave', 'r1mmer']

handshaker = new Handshaker()

web_client.get_session_id username, password, (session_id) ->
  u.log("Retrieved session id: #{session_id}")
  
  handshaker.handshake username, (server_hash) ->
    web_client.join_server username, session_id, server_hash, ->
      handshaker.sendLoginRequest()