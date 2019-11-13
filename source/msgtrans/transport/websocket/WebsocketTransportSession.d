module msgtrans.transport.websocket.WebsocketTransportSession;

// import msgtrans.transport.TransportSession;
// import msgtrans.MessageBuffer;

// import hunt.http.codec.websocket.frame;
// import hunt.http.codec.websocket.stream.WebSocketConnection;
// import hunt.http.HttpConnection;

// import hunt.net;
// import hunt.String;

// class WebsocketTransportSession : TransportSession {

//     private
//     {
//         WebSocketConnection _conn = null;
//     }

//     this(WebSocketConnection connection) {
//         _conn = connection;
//     }

//     override void sendMsg(MessageBuffer message)
//     {
//         if (_conn.getTcpConnection().isConnected())
//         {
//             _conn.sendData(cast(byte[])message.encode());
//         }
//     }

//     WebSocketConnection getConnection()
//     {
//         return _conn;
//     }

//     override string getProtocol()
//     {
//         return (cast(String)_conn.getTcpConnection().getAttribute(SESSION.PROTOCOL)).value;
//     }

//     override Connection getConnection()
//     {
//         return _conn.getTcpConnection();
//     }

//     override void close()
//     {
//         if (_conn !is null && _conn.getTcpConnection().getState !is ConnectionState.Closed)
//         {
//             _conn.getTcpConnection().close();
//         }
//     }

//     override bool isConnected()
//     {
//         return _conn.getTcpConnection().isConnected();
//     }
// }
