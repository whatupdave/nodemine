u         = require 'util'
net       = require 'net'

WebClient = require './web_client'
packet    = require './packet'


class exports.Handshaker
  constructor: -> @packetId = null
  
  log: (message) -> u.log "SOCKET> #{message}"
  
  handshake: (@username, @web_join_callback) =>
    @socket = net.createConnection(25565, "173.255.214.92")
    @socket.on "connect", =>
      @log "Connected"
      @sendHandshakeInit(@socket, username)
    
    @socket.on "data", @handleIncoming
  
  sendHandshakeInit: =>
    handshake_request = packet.spec id: 0x02, username: 'string'
    buffer = handshake_request.create username: @username
    @socket.write buffer
        
      
  sendLoginRequest: =>
    login_request = packet.spec 
      id: 0x01
      version: 'int'
      username: 'string'
      password: 'string'
      map_seed: 'long'
      dimension: 'byte'
      
    @socket.write login_request.create
      version: 9
      username: @username
      password: 'r1mmer'
      map_seed: 0
      dimension: 0
    
  
  handleIncoming: (buffer) =>
    if @packetId?
      @log "RECV > header: 0x#{@packetId.toString(16)}"
      response_handler = switch @packetId
        when 0x01 then @login_response
        when 0x02 then @handshake_response
        when 0xFF then @error_response
      
      @packetId = null
      
      response_handler buffer
    else
      @packetId = buffer[0]

  login_response: (buffer) =>
    login_response_spec = packet.spec 
      entity_id: 'int'
      unknown1: 'string'
      unknown2: 'string'
      map_seed: 'long'
      dimension: 'byte'
    
    p = login_response_spec.parse buffer
    
    @log "Login successful. Player ID: #{p.entity_id}"
    
  handshake_response: (buffer) =>
    handshake_response_spec = packet.spec server_hash: 'string'
    p = handshake_response_spec.parse buffer
    @log "Server hash: #{p.server_hash}"
    @web_join_callback p.server_hash
    
  error_response: (buffer) =>
    @log("Server Error: #{buffer}")