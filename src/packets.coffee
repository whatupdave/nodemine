u = require 'util'
packet = require './packet'

exports.client = client_packets = {}
exports.server = server_packets = {}
exports.server_id = server_id_packets = {}

client_packet = (id, name, specified_fields) ->
  fields = { id: id }
  for k,v of specified_fields
    fields[k] = v
  
  client_packets[name] = packet.spec fields
  
server_packet = (id, name, fields) ->
  packet_spec = packet.spec fields
  server_packets[name] = packet_spec
  server_id_packets[id] = name: name, spec: packet_spec

client_packet 0x00, "keepalive"

client_packet 0x01, "login"
  version:    'int'
  username:   'string'
  password:   'string'
  map_seed:   'long'
  dimension:  'byte'

server_packet 0x01, "login"
  entity_id:    'int'
  server_name:  'string'
  motd:         'string'
  map_seed:     'long'
  dimension:    'byte'


client_packet 0x02, "handshake"
  username: 'string'
  
server_packet 0x02, "handshake"
  server_hash: 'string'
  
server_packet 0x10, "holding_change"
  slot_id: 'short'
  
server_packet 0xFF, "error"
  message: 'string'