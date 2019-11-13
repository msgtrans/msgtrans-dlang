module msgtrans.ConnectionManager;

// import msgtrans.Session;

// import msgtrans.protocol.protobuf.TcpSession;
// import msgtrans.protocol.http.HttpConnection;
// import msgtrans.protocol.websocket.WebsocketTransportSession;
// import msgtrans.protocol.protobuf.TcpConnectionEventHandler;
// import msgtrans.protocol.http.HttpConnectionEventHandler;
// import msgtrans.protocol.websocket.WebsocketTransportSessionEventHandler;

// import hunt.http.codec.websocket.stream.WebsocketSession;

// import hunt.collection.HashMap;

// import hunt.net;
// import hunt.logging;

// import std.conv : to;

// class ConnectionManager(T) {

//     alias CloseCallBack = void delegate(Session connection);

//     private {
//         HashMap!(T,Session) _mapConns;
//         string _protocolName;
//         CloseCallBack _onClosed = null;
//     }

//     this ()
//     {
//         _mapConns = new HashMap!(T,Session);
//     }


//     void onConnection(Session connection)
//     {
//         synchronized(this)
//         {
//             trace("----------------put--%s",connection.getProtocol());
//             _mapConns.put(connection.getConnection().getId().to!T,connection);
//         }
//     }

//     void onClosed(Session connection)
//     {
//         if (_onClosed !is null)
//         {
//             _onClosed(connection);
//         }
        
//         synchronized(this){
//             trace("----------------del--%s",connection.getProtocol());
//             _mapConns.remove(connection.getConnection().getId().to!T);
//         }
//     }

//     Session getConnection(T connId)
//     {
//         synchronized(this)
//         {
//            return  _mapConns.get(connId);
//         }
//     }

//     void putConnection(T connId ,Session conn)
//     {
//         synchronized(this)
//         {
//             _mapConns.put(connId,conn);
//         }
//     }

//     void removeConnection(T connId)
//     {
//         synchronized(this)
//         {
//             _mapConns.remove(connId);
//         }
//     }

//     bool isExist(T connId)
//     {
//         HashMap!(T,Session) temp = null;
//         synchronized(this)
//         {
//             temp = _mapConns;
//         }
//         return temp.containsKey(connId);
//     }

//     void setProtocolName(string name)
//     {
//         _protocolName = name;
//     }

//     string getProtocolName()
//     {
//         return _protocolName;
//     }

//     void setCloseHandler (CloseCallBack callback)
//     {
//         _onClosed = callback;
//     }
// }
