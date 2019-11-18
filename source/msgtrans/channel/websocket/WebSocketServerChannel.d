module msgtrans.channel.websocket.WebSocketServerChannel;

import msgtrans.executor;
import msgtrans.PacketParser;
import msgtrans.MessageBuffer;
import msgtrans.channel.ServerChannel;
import msgtrans.SessionManager;
import msgtrans.channel.TransportContext;
import msgtrans.channel.TransportSession;
import msgtrans.channel.websocket.WebSocketTransportSession;
import msgtrans.channel.websocket.WebSocketChannel;

import hunt.collection.ByteBuffer;
import hunt.http.server;
import hunt.logging.ConsoleLogger;
import hunt.net;
import hunt.util.DateTime;

import std.format;
import std.stdio;


/** 
 * 
 */
class WebSocketServerChannel : WebSocketChannel, ServerChannel {
    private HttpServer _server;
    private SessionManager _sessionManager;
    private string _name = typeof(this).stringof;
    private string _host = "0.0.0.0";
    private ushort _port = 8080;
    private string _path = "/*";


    this(ushort port , string path) {
        _port = port;
        _path = path;
    }

    string name() {
        return _name;
    }

    void start() {
        initialize();
        
        _server.onOpened(() {
                if(_server.isTLS())
                    writefln("listening on https://%s:%d", _server.getHost, _server.getPort);
                else 
                    writefln("listening on http://%s:%d", _server.getHost, _server.getPort);
            })
            .onOpenFailed((e) {
                writefln("Failed to open a HttpServer, the reason: %s", e.msg);
            })
            .start();
    }
    
    void stop() {
        if(_server !is null)
            _server.stop();
    }

    void setSessionManager(SessionManager manager) {
        _sessionManager = manager; 
    }

    private void initialize() {
        _server = HttpServer.builder()
            // .setTLS("cert/server.crt", "cert/server.key", "hunt2018", "hunt2018")
            .setListener(_port, _host)
            .registerWebSocket(_path, new class AbstractWebSocketMessageHandler {

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
            })
            .build();
    }
    
    override protected void dispatchMessage(WebSocketConnection connection, MessageBuffer message ) {
        version(HUNT_DEBUG) {
            string str = format("data received: %s", message.toString());
            tracef(str);
        }

        // rx: 00 00 27 11 00 00 00 05 00 00 00 00 00 00 00 00 57 6F 72 6C 64
        // tx: 00 00 4E 21 00 00 00 0B 00 00 00 00 00 00 00 00 48 65 6C 6C 6F 20 57 6F 72 6C 64
        
        uint messageId = message.id;
        ExecutorInfo executorInfo = Executor.getExecutor(messageId);
        if(executorInfo == ExecutorInfo.init) {
            warning("No Executor found for id: ", messageId);
        } else {
            enum string ChannelSession = "ChannelSession";
            WebsocketTransportSession session = cast(WebsocketTransportSession)connection.getAttribute(ChannelSession);
            if(session is null ){
                session = new WebsocketTransportSession(_sessionManager.genarateId(), messageId, connection);
                connection.setAttribute(ChannelSession, session);
                _sessionManager.add(session);
            }
            
            TransportContext context = TransportContext(_sessionManager, session);
            executorInfo.execute(context, message);
        }
    }

    // override ulong nextSessionId() {
    //     return _sessionManager.genarateId();
    // }

}
