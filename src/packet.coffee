
Buffer::read_byte = (index) ->
  @[index]

Buffer::read_short = (index) ->
  (@[index + 0] << 8) + 
  (@[index + 1])

Buffer::read_int = (index) ->
  (@[index + 0] << 24) + 
  (@[index + 1] << 16) +
  (@[index + 2] << 8)  + 
  (@[index + 3])

Buffer::read_long = (index) ->
  (@[index + 0] << 56) + 
  (@[index + 1] << 48) +
  (@[index + 2] << 40) + 
  (@[index + 3] << 32) +
  (@[index + 0] << 24) + 
  (@[index + 1] << 16) +
  (@[index + 2] << 8)  + 
  (@[index + 3])

Buffer::read_string = (index) ->
  length = @read_short index
  b = @slice index + 2, index + 2 + length
  b.toString()

Buffer::write_byte = (byte, index) ->
  @[index] = byte
  1

Buffer::write_short = (short, index) ->
  @[index + 0] = short >> 8
  @[index + 1] = short
  2

Buffer::write_int = (int, index) ->
  @[index + 0] = int >> 24
  @[index + 1] = int >> 16
  @[index + 2] = int >> 8
  @[index + 3] = int
  4
  
Buffer::write_long = (long, index) ->
  @[index + 0] = long >> 56
  @[index + 1] = long >> 48
  @[index + 2] = long >> 40
  @[index + 3] = long >> 32
  @[index + 4] = long >> 24
  @[index + 5] = long >> 16
  @[index + 6] = long >> 8
  @[index + 7] = long
  8
  
Buffer::write_string = (string, index) ->
  write_count = 0
  write_count += @write_short string.length, index + write_count
  write_count += @write string, index + write_count
  write_count

type_lengths =
  byte:   1
  short:  2
  int:    4
  long:   8
  float:  4
  double: 8
  bool:   1

field_length = (name, type, value) ->
  if name is 'id'
    1
  else if type is 'string'
    value.length + 2
  else
    type_lengths[type]

exports.spec = (field_types) ->

  create: (field_values) ->
    field_sizes = for field_name, field_type of field_types
      field_length field_name, field_type, field_values[field_name]
        
    buffer_size = field_sizes.reduce (a,b) -> a + b
    
    buffer = new Buffer(buffer_size)
    buffer_index = 0

    for field_name, field_type of field_types
      field_value = field_values[field_name]
      if field_name is 'id'
        buffer_index += buffer.write_byte(field_type, buffer_index)
      else
        buffer_index += buffer["write_#{field_type}"](field_value, buffer_index)
    
    buffer
    
  parse: (buffer) ->
    buffer_index = 0
    
    packet = {}
    for field_name, field_type of field_types
      packet[field_name] = buffer["read_#{field_type}"](buffer_index)
      buffer_index += field_length field_name, field_type, packet[field_name]
      
    packet