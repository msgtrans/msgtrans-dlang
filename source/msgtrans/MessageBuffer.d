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

struct Extend
{
   uint tagId;
   uint userIp;
   uint userId;
}

class MessageBuffer
{
    uint id;
    ubyte compression;
    //uint tagId;
    //uint clientId;
    //uint extendLength;
    ubyte[] data;
    Extend extend;
    bool hasExtend;

    this()
    {
        id = 0;
        compression = 0;
        hasExtend = false;
        //extendLength = 0;
        //tagId = 0;
        //clientId = 0;
    }

    this(uint id, ubyte[] data) {
      this.id = id;
      this.data = data;
      hasExtend = false;
      //this.extendLength = 0;
      //this.clientId = 0;
    }

    this(uint id, ubyte[] data , Extend extend) {
        this.id = id;
        this.data = data;
        this.extend = extend;
        hasExtend = true;
        //this.tagId = tagId;
        //this.extendLength = uint.sizeof;
        //this.clientId = 0;
       // this.extend = nativeToBigEndian(tagId);
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
