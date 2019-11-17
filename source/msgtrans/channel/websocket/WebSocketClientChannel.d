module msgtrans.channel.websocket.WebSocketClientChannel;

import msgtrans.Packet;
import msgtrans.MessageBuffer;
import msgtrans.Executor;
import msgtrans.channel.ClientChannel;
import msgtrans.channel.TransportSession;
import msgtrans.channel.websocket.WebSocketChannel;

import hunt.collection.ByteBuffer;
import hunt.Exceptions;
import hunt.http.client;
import hunt.logging.ConsoleLogger;
import hunt.net;

import hunt.concurrency.FuturePromise;

import core.sync.condition;
import core.sync.mutex;

import std.format;
import std.range;

/** 
 * 
 */
class WebSocketClientChannel : WebSocketChannel, ClientChannel {
    private HttpURI _url;
    
    private HttpClient _client;
    private WebSocketConnection _connection;
    

    this(string host, ushort port, string path) {
        if(path.empty() || path[0] != '/')
            throw new Exception("Wrong path: " ~ path);
        string url = format("ws://%s:%d%s", host, port, path);
        this(new HttpURI(url));
    }

    this(string url) {
        this(new HttpURI(url));
    }

    this(HttpURI url) {
        _url = url;
        _client = new HttpClient();
    }

    void connect() {

        if(_connection !is null) {
            return;
        }
        
        Request request = new RequestBuilder()
            .url(_url)
            // .authorization(AuthenticationScheme.Basic, "cHV0YW86MjAxOQ==")
            .build();
        
        
        _connection = _client.newWebSocket(request, new class AbstractWebSocketMessageHandler {
            override void onOpen(WebSocketConnection connection) {
                version(HUNT_DEBUG) infof("New connection from: %s", connection.getRemoteAddress());
            }

            override void onText(WebSocketConnection connection, string text) {
                version(HUNT_DEBUG) tracef("received (from %s): %s", connection.getRemoteAddress(), text); 
            }
            
            override void onBinary(WebSocketConnection connection, ByteBuffer buffer)  { 
                byte[] data = buffer.getRemaining();
                version(HUNT_DEBUG) {
                    tracef("received (from %s): %s", connection.getRemoteAddress(), buffer.toString()); 
                    if(data.length<=64)
                        infof("%(%02X %)", data[0 .. $]);
                    else
                        infof("%(%02X %) ...(%d bytes)", data[0 .. 64], data.length);
                }
                
                if(data.length > 0) {
                    decode(connection, buffer);
                }
            }
        });

    }

    bool isConnected() {
        return _connection !is null && _connection.getTcpConnection().isConnected();
    }

    override ulong nextSessionId() {
        return nextClientSessionId();
    }

    void send(MessageBuffer message) {
        if(!isConnected()) {
            throw new IOException("Connection broken!");
        }

        ubyte[][] buffers = Packet.encode(message);
        foreach(ubyte[] data; buffers) {
            _connection.sendData(cast(byte[])data);
        }
    }

    void close() {
        if(_client !is null) {
            _client.close();
        }
    }


}


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
