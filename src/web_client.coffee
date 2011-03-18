http = require 'http'
u = require 'util'

log = (message) -> u.log "HTTP> #{message}"

exports.get_session_id = (username, password, callback) ->
  options =
    host: 'www.minecraft.net'
    path: '/game/getversion.jsp'
    method: 'POST'
    headers: 'Content-Type': 'application/x-www-form-urlencoded'
  
  request = http.request options, (response) -> 
    response.on "data", (chunk) -> 
      body = chunk.toString('ascii')
      [gameFilesVersion, downloadTicket, username, sessionId] = body.split(":")
      
      callback(sessionId)
  
  request.end("user=#{username}&password=#{password}&version=12")
  log "Requesting session id. #{request.path}"
  

exports.join_server = (username, session_id, server_hash, callback) ->
  options =
    host: '50.16.200.224'
    path: "/game/joinserver.jsp?user=#{username}&sessionId=#{session_id}&serverId=#{server_hash}"
  
  request = http.request options, (response) ->
    response.on "data", (chunk) ->
      body = chunk.toString('ascii')
      u.log "Reply: #{body}"
      callback()
    
  request.end()
  log "authenticating server"
    