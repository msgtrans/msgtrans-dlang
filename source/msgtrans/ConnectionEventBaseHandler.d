module msgtrans.ConnectionEventBaseHandler;

import hunt.net;

// import msgtrans.Session;

// class ConnectionEventBaseHandler : ConnectionEventHandler
// {
//     alias ConnCallBack = void delegate( Session connection);
//     alias MsgCallBack = void delegate(Connection connection ,Object message);

//     override
//     void connectionOpened(Connection connection) {}

//     override
//     void connectionClosed(Connection connection) {}

//     override
//     void messageReceived(Connection connection, Object message) {}

//     override
//     void exceptionCaught(Connection connection, Throwable t) {}

//     override
//     void failedOpeningConnection(int connectionId, Throwable t) { }

//     override
//     void failedAcceptingConnection(int connectionId, Throwable t) { }

//     void setOnConnection(ConnCallBack callback)
//     {
//     }

//     void setOnClosed(ConnCallBack callback)
//     {
//     }

//     void setOnMessage(MsgCallBack callback)
//     {
//     }
// }