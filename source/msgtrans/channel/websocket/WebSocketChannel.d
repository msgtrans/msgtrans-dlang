module msgtrans.channel.websocket.WebSocketChannel;

import msgtrans.executor;
import msgtrans.PacketParser;
import msgtrans.MessageBuffer;
import msgtrans.channel.websocket.WebSocketTransportSession;

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
abstract class WebSocketChannel {
    
    /** The default maximum buffer length. Default to 128 chars. */
    private int bufferLength = 128;

    /** The default maximum Line length. Default to 1024. */
    private int maxLineLength = 8*1024;

    protected void decode(WebSocketConnection connection, ByteBuffer buf) { 
        PacketParser parser = getParser(connection);

        MessageBuffer[] msgBuffers = parser.parse(buf);
        if(msgBuffers is null) {
            warning("no message frame parsed.");
            return;
        }

        foreach(MessageBuffer msg; msgBuffers) {
            dispatchMessage(connection, msg);
        }
    } 

    protected PacketParser getParser(WebSocketConnection connection) {
        enum string PARSER = "PacketParser";
        PacketParser ctx;
        ctx = cast(PacketParser) connection.getAttribute(PARSER);

        if (ctx is null) {
            ctx = new PacketParser(bufferLength);
            connection.setAttribute(PARSER, ctx);
        }

        return ctx;
    }

    ulong nextSessionId();
    
    protected void dispatchMessage(WebSocketConnection connection, MessageBuffer message ) {
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
                session = new WebsocketTransportSession(nextSessionId(), connection);
                connection.setAttribute(ChannelSession, session);
            }
            executorInfo.execute(session, message);
        }
    }

}