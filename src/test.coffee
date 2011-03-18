
# Need to pass username, password and server as args

SocketClient = require('./socket_client').SocketClient
MessageHandler = require('./message_handler').MessageHandler

[a, b, username, password, server] = process.argv

socket_client = new SocketClient(new MessageHandler())


socket_client.connect username, password, server

