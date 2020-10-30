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
    uint tagId;

    uint extendLength;
    ubyte[] data;
   // ubyte[] extend;

    this()
    {
        id = 0;
        compression = 0;
        extendLength = 0;
        tagId = 0;
    }

    this(uint id, ubyte[] data) {
      this.id = id;
      this.data = data;
      this.extendLength = 0;
    }

    this(uint id, ubyte[] data , uint tagId) {
        this.id = id;
        this.data = data;
        this.tagId = tagId;
        this.extendLength = uint.sizeof;
       // this.extend = nativeToBigEndian(tagId);
    }

    override string toString() {
        return format("id: %d, length: %d", id, data.length);
    }
}
