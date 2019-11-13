module msgtrans.transport.websocket.WebsocketTransportClient;

// import hunt.http.client.ClientHttpHandler;
// import hunt.http.client.HttpClient;
// import hunt.http.client.HttpClientConnection;
// import hunt.http.client.HttpClientRequest;
// import hunt.http.HttpOptions;
// import hunt.http.HttpConnection;
// import hunt.http.codec.http.stream.HttpOutputStream;
// import hunt.http.codec.websocket.frame;
// import hunt.http.codec.websocket.model.IncomingFrames;
// import hunt.http.codec.websocket.stream.WebSocketConnection;
// import hunt.http.codec.websocket.stream.WebSocketPolicy;
// import hunt.concurrency.Promise;
// import hunt.concurrency.Future;
// import hunt.concurrency.FuturePromise;
// import hunt.concurrency.CompletableFuture;
// import hunt.http.client.HttpClientOptions;
// import msgtrans.transport.websocket.GatewayClient;
// import msgtrans.protocol.Protocol;
// import google.protobuf;
// import std.array;
// import msgtrans.Session;
// import msgtrans.protocol.websocket.WebsocketTransportSession;
// import hunt.net;
// import hunt.logging;
// import msgtrans.MessageBuffer;

// class ClientHttpHandlerEx : AbstractClientHttpHandler {
//     import hunt.http.codec.http.model;

//     override public bool messageComplete(HttpRequest request,
//     HttpResponse response, HttpOutputStream output, HttpConnection connection) {
//         tracef("upgrade websocket success: " ~ response.toString());
//         return true;
//     }
// }

// class IncomingFramesEx : IncomingFrames
// {
//     private
//     {
//         Session _conn;
//     }

//     void setWebsocketTransportSession(Session connection)
//     {
//         _conn = connection;
//     }

//     override public void incomingError(Exception t) {
//     }
//     override public void incomingFrame(Frame frame) {
//         FrameType type = frame.getType();
//         switch (type) {
//             case FrameType.TEXT:
//             {
//                 break ;
//             }
//             case FrameType.BINARY:
//             {
//                 BinaryFrame binFrame = cast(BinaryFrame) frame;
//                 Session.dispatchMessage( _conn,MessageBuffer.decode( cast(ubyte[])binFrame.getPayload().getRemaining()));
//                 break ;
//             }
//             default:
//             break ;
//         }
//     }
// }

// class WebsocketTransportClient : GatewayClient
// {
//     private
//     {
//         HttpClientConnection _connection;

//         string _host;
//         string _path;
//         ushort _port;
        
//         Session _conn = null;
//     }

//     this(ushort port, string path)
//     {
//         _host = "127.0.0.1";
//         _port = port;
//         _path = path;
//     }

//     void connect()
//     {
//         HttpClient client = new HttpClient(new HttpClientOptions());
//         Future!(HttpClientConnection) conn = client.connect(_protocol.getHost(), _protocol.getPort());
//         _connection = conn.get();

//         auto promise = new FuturePromise!WebSocketConnection();
//         auto incomingFramesEx = new IncomingFramesEx();

//         _connection.upgradeWebSocket(new HttpClientRequest("GET", _path), WebSocketPolicy.newClientPolicy(), promise, new ClientHttpHandlerEx(), incomingFramesEx);
        
//         WebSocketConnection connection = promise.get();

//         _conn = new WebsocketTransportSession(connection);

//         incomingFramesEx.setWebsocketTransportSession(_conn);
//     }

//     void sendMsg(T)(int tid, T t)
//     {
//         if (_conn !is null)
//         {
//             MessageBuffer ask = new MessageBuffer(tid, t.toProtobuf.array);
//             _conn.sendMsg(ask);
//         }
//     }

//     void onConnection (Session connection)
//     {

//     }

//     void onClosed (Session connection)
//     {

//     }
// }
