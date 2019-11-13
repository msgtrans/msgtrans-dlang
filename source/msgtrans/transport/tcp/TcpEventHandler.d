module msgtrans.transport.tcp.TcpEventHandler;

// // import msgtrans.transport.tcp.TcpSession;
// import msgtrans.ConnectionEventBaseHandler;
// import msgtrans.Session;
// import msgtrans.MessageBuffer;

// import hunt.net;
// import hunt.String;

// import std.stdio;

// class TcpEventHandler : ConnectionEventBaseHandler
// {
//     //alias ConnCallBack = void delegate(Session connection);
//     //alias MsgCallBack = void delegate(Connection connection ,Object message);

//     this(string attribute){
//         _attribute = attribute;
//     }

//     override
//     void connectionOpened(Connection connection)
//     {
//         if (_onConnection !is null)
//         {
//             connection.setAttribute(SESSION.PROTOCOL,new String(_attribute));
//             TcpSession conn = new TcpSession(connection);
//             _onConnection(conn);
//         }
//     }

//     override
//     void connectionClosed(Connection connection)
//     {
//         connection.setState(ConnectionState.Closed);
//         if (_onClosed !is null )
//         {
//             TcpSession conn = new TcpSession(connection);
//             _onClosed(conn);
//         }
//     }

//     override
//     void messageReceived(Connection connection, Object message)
//     {
//         MessageBuffer msg = cast(MessageBuffer)message;
//         Session.dispatchMessage(new TcpSession(connection),msg);
//     }

//     override
//     void exceptionCaught(Connection connection, Throwable t)
//     {

//     }

//     override
//     void failedOpeningConnection(int connectionId, Throwable t) { }

//     override
//     void failedAcceptingConnection(int connectionId, Throwable t) { }

//     override
//     void setOnConnection(ConnCallBack callback)
//     {
//         _onConnection = callback;
//     }

//     override
//     void setOnClosed(ConnCallBack callback)
//     {
//         _onClosed = callback;
//     }

//     override
//     void setOnMessage(MsgCallBack callback)
//     {
//         _onMessage = callback;
//     }

// private
// {
//     string _attribute = null;
//     ConnCallBack _onConnection = null;
//     ConnCallBack _onClosed = null;
//     MsgCallBack _onMessage = null;
// }

// }

