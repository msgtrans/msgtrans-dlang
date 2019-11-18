module msgtrans.channel.websocket.WebSocketClientChannel;

import msgtrans.Packet;
import msgtrans.MessageBuffer;
import msgtrans.executor;
import msgtrans.channel.ClientChannel;
import msgtrans.channel.SessionManager;
import msgtrans.channel.TransportSession;
import msgtrans.channel.websocket.WebSocketChannel;
import msgtrans.channel.websocket.WebSocketTransportSession;

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

    override protected void dispatchMessage(WebSocketConnection connection, MessageBuffer message ) {
        version(HUNT_DEBUG) {
            string str = format("data received: %s", message.toString());
            tracef(str);
        }

        // rx: 00 00 27 11 00 00 00 05 00 00 00 00 00 00 00 00 57 6F 72 6C 64
        // tx: 00 00 4E 21 00 00 00 0B 00 00 00 00 00 00 00 00 48 65 6C 6C 6F 20 57 6F 72 6C 64
        
        ExecutorInfo executorInfo = Executor.getExecutor(message.id);
        if(executorInfo == ExecutorInfo.init) {
            warning("No Executor found for id: ", message.id);
        } else {
            enum string ChannelSession = "ChannelSession";
            WebsocketTransportSession session = cast(WebsocketTransportSession)connection.getAttribute(ChannelSession);
            if(session is null ){
                session = new WebsocketTransportSession(nextClientSessionId(), connection);
                connection.setAttribute(ChannelSession, session);
            }
            executorInfo.execute(session, message);
        }
    }    
}
