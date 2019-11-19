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

module msgtrans.MessageBuffer;

import std.format;

/** 
 * 
 */
class MessageBuffer
{
    uint id;
    ubyte[] data;

    this(uint id, ubyte[] data) {
        this.id = id;
        this.data = data;
    }

    override string toString() {
        return format("id: %d, length: %d", id, data.length);
    }
}
