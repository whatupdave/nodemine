u         = require 'util'
net       = require 'net'

web_client = require './web_client'
packets    = require './packets'

# Will do the initial connection handshake dance then defer to message handler
class exports.SocketClient
  constructor: (@handler) -> 
    @packet_id = null
  
  log: (message) -> u.log "SOCKET> #{message}"
  
  connect: (@username, @password, @server) =>
    web_client.get_session_id @username, @password, (session_id) =>
      @log("got session id: #{session_id}")
      @session_id = session_id
      @connect_socket()
  
  connect_socket: =>
    @socket = net.createConnection(25565, @server)
    @socket.on "connect", =>
      @log "Connected"
      @socket.write packets.client.handshake.create username: @username
    
    @socket.on "data", @handle_incoming_packet
    @socket.on "error", (exception) -> "Error: #{exception}"
  
  handle_incoming_packet: (buffer) =>
    if @packet_id?
      @log "RECV > header: 0x#{@packet_id.toString(16)}"

      incoming_packet = packets.server_id[@packet_id.toString()]

      if incoming_packet
        handler_method = switch incoming_packet.name
          when 'handshake' then @received_handshake
          else @handler[incoming_packet.name]

        handler_method incoming_packet.spec.parse buffer if handler_method
      
      @packet_id = null
    else
      @packet_id = buffer[0]

  received_handshake: (data) =>
    @log "Server hash: #{data.server_hash}"
    web_client.join_server @username, @session_id, data.server_hash, =>
      @send_login()

  send_login: =>
    @socket.write packets.client.login.create
      version: 9
      username: @username
      password: 'Password'
      map_seed: 0
      dimension: 0
    u.log "Logging into server"
