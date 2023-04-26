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

module msgtrans.channel.tcp.TcpTransportSession;

import msgtrans.Packet;
import msgtrans.MessageBuffer;
import msgtrans.channel.TransportSession;
import msgtrans.e2ee.message.MsgDefine;
import msgtrans.e2ee.crypto;
import msgtrans.e2ee.common;
import msgtrans.MessageTransportServer;
import hunt.net;
import hunt.String;

import std.stdio;
import std.array;

/**
 *
 */
class TcpTransportSession : TransportSession {
    private Connection _conn = null;

    this(long id, Connection connection) {
        _conn = connection;
        super(id);
    }

    override Object getAttribute(string key) {
        return _conn.getAttribute(key);
    }

    override void setAttribute(string key, Object value) {
        _conn.setAttribute(key, value);
    }

    override bool containsAttribute(string key) {
        return _conn.containsAttribute(key);
    }


    override void send(MessageBuffer message) {
        if (_conn.isConnected()) {

            if (MessageTransportServer.isE2EE && (message.id != MESSAGE.INITIATE  && message.id != MESSAGE.FINALIZE))
            {
                peerkey_s peerkeys = cast(peerkey_s)(getAttribute("E2EE"));
                message = common.encrypted_encode(message,null, peerkeys);
            }

            ubyte[][] buffers = Packet.encode(message);
            foreach(ubyte[] data; buffers) {
                _conn.write(data);
                //writefln("data : %s",data);
            }
        }
    }

    override void close() {
        if (_conn !is null && _conn.getState() !is ConnectionState.Closed) {
            _conn.close();
        }
    }

    override bool isConnected() {
        return _conn.isConnected();
    }
}
