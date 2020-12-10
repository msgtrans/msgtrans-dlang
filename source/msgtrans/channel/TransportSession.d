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

module msgtrans.channel.TransportSession;

import msgtrans.MessageBuffer;
import msgtrans.DefaultSessionManager;

import hunt.serialization.JsonSerializer;
import hunt.net;
import hunt.logging;

import core.atomic;
import std.stdint;
import std.bitmanip;

/** 
 * 
 */
abstract class TransportSession {

    private ulong _id;

    this(ulong id) {
        _id = id;
    }

    ulong id() {
        return _id;
    }

    Object getAttribute(string key);

    void setAttribute(string key, Object value);

    bool containsAttribute(string key);

    void send(MessageBuffer buffer);

    void send(uint messageId, string content) {
        send(new MessageBuffer(messageId, cast(ubyte[]) content));
    }

    void close();

    bool isConnected();
}
