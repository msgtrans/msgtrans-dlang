/*
 * MsgTrans - Message Transport Framework for DLang. Based on TCP, WebSocket, UDP transmission protocol.
 *
 * Copyright (C) 2019 HuntLabs
 *
 * Website: https://www.msgtrans.org
 *
 * Licensed under the Apache-2.0 License.
 *
 */

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

    protected void dispatchMessage(WebSocketConnection connection, MessageBuffer message );
}
