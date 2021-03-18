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
import std.bitmanip;

/**
 *
 */
class MessageBuffer
{
    uint id;
    ubyte compression;
    uint extendLength;
    ubyte[] data;
    ubyte[] extend;
    bool hasExtend;

    this() {
        id = 0;
        compression = 0;
        hasExtend = false;
        extendLength = 0;
    }


    this(uint id, string data) {
        this(id, cast(ubyte[])data.dup);
    }

    this(uint id, ubyte[] data) {
        this.id = id;
        this.data = data;
        hasExtend = false;
        this.extendLength = 0;
    }

    this(uint id, ubyte[] data , ubyte[] extend) {
        this.id = id;
        this.data = data;
        //this.extend = extend;
        this.extendLength = cast(int)(extend.length);
        //this.extend = new ubyte[extendLength];
        this.extend = extend;
        hasExtend = true;

    }

    //this(uint id, ubyte[] data, uint tagId, uint clientId)
    //{
    //    this.id = id;
    //    this.data = data;
    //    this.tagId = tagId;
    //    this.extendLength = uint.sizeof + uint.sizeof;
    //    this.clientId = clientId;
    //}

    override string toString() {
        return format("id: %d, length: %d", id, data.length);
    }
}
