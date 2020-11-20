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

module msgtrans.PacketHeader;

import msgtrans.MessageBuffer;
import std.bitmanip;
import std.format;
import std.stdint;
import hunt.logging;
/* -------------------------------------------------------------------------- */
/*                                  protocol                                  */
/* -------------------------------------------------------------------------- */

enum int ID_FIELD_LENGTH = uint.sizeof;
enum int LENGTH_FIELD_LENGTH = uint.sizeof;
enum int COMPRESSION_FIELD_LENGTH = byte.sizeof;
// enum int RESERVED_FILED_LENGTH = -;
enum int EXTENSION_FIELD_LENGTH = uint.sizeof;
enum int PACKET_HEADER_LENGTH = 16;

enum int MAX_PACKET_SIZE = 4 * 1024 * 1024; // 4M

// Used to filter the invalid data
__gshared uint[] AvaliableMessageIds = [];

/* -------------------------------------------------------------------------- */

// enum SERIALIZATION_TYPE : ushort {
//     NONE,
//     JSON,
//     MSGPACK,
//     PROTOBUF,
//     FLATBUFFERS
// }

// enum ENCRYPT_TYPE : ushort {
//     NONE,
//     ACE_256,
//     ACE_512
// }

// enum COMPACTION_TYPE : ushort {
//     NONE,
//     L4,
//     ZIP,
//     GZIP,
//     LZMA
// }

/**
 *
 */
class PacketHeader
{

    private
    {
        // Message ID
        uint _messageID = 0;

        // Message data length
        uint _messageLength = 0;

        ubyte _compressionType;

        uint _extendLength;
        // Serialization type including json, protobuf, msgpack, flatbuffers and more
        // ushort _serializationType = 0;

        // used encrypt algorithm, 0 is none
        // ushort _encryptType = 0;

        // used compaction algorithm, 0 is none
        // ushort _compactionType = 0;
    }

    this(uint id, uint length, uint extlen)
    {
        _messageID = id;
        _messageLength = length;
        //_compressionType = compr;
        _extendLength = extlen;
    }

    static PacketHeader parse(ubyte[] data)
    {
        // if (data.length < PACKET_HEADER_LENGTH)
        // {
        //     return null;
        // }
        // NOTE: Byte ordering is big endian.
        logInfo("ID_FIELD_LENGTH: %d",ID_FIELD_LENGTH);
        ubyte[ID_FIELD_LENGTH] idBytes = data[0..ID_FIELD_LENGTH];
        uint id = bigEndianToNative!(uint)(idBytes);
        if(id == 0) {
            return null;
        }

        enum LengthStart = ID_FIELD_LENGTH;
        enum LengthEnd = ID_FIELD_LENGTH + LENGTH_FIELD_LENGTH;
        ubyte[LENGTH_FIELD_LENGTH] lengthBytes = data[LengthStart..LengthEnd];
        uint length = bigEndianToNative!uint(lengthBytes);


        enum LengthCompression  = LengthEnd +  COMPRESSION_FIELD_LENGTH;
        ubyte[COMPRESSION_FIELD_LENGTH] compression = data[LengthEnd .. LengthCompression];
        ubyte ucompre = (bigEndianToNative!ubyte(compression));

        enum LengthExtend = LengthCompression + EXTENSION_FIELD_LENGTH;
        ubyte[EXTENSION_FIELD_LENGTH] ex = data[LengthCompression .. LengthExtend];
        uint extendLen = bigEndianToNative!uint(ex);

        return new PacketHeader(id, length ,extendLen);
    }

    static ubyte[] encode(MessageBuffer message) {
        ubyte[ID_FIELD_LENGTH] h0 = nativeToBigEndian(message.id);
        ubyte[LENGTH_FIELD_LENGTH] h1 = nativeToBigEndian(cast(int)(message.data.length));
        ubyte[COMPRESSION_FIELD_LENGTH] h2 = message.compression;
        ubyte[EXTENSION_FIELD_LENGTH] h3;
        if (message.hasExtend)
        {
          h3 = nativeToBigEndian(cast(int)Extend.sizeof);
        }else
        {
          h3 = nativeToBigEndian(0);
        }


        ubyte[] buffer = new ubyte[PACKET_HEADER_LENGTH];
        buffer[0..ID_FIELD_LENGTH] = h0[];

        int lengthStart = ID_FIELD_LENGTH;
        int lengthEnd1 = lengthStart + LENGTH_FIELD_LENGTH;

        buffer[lengthStart .. lengthEnd1] = h1[];

        int lengthEnd2 = lengthEnd1 + COMPRESSION_FIELD_LENGTH;

        buffer[lengthEnd1 .. lengthEnd2] = h2[];

        int lengthEnd3 = lengthEnd2 + EXTENSION_FIELD_LENGTH;

        buffer[lengthEnd2 .. lengthEnd3] = h3[];

        return buffer;
    }

    ubyte[] data()
    {
        ubyte[ID_FIELD_LENGTH] h0 = nativeToBigEndian(_messageID);
        ubyte[LENGTH_FIELD_LENGTH] h1 = nativeToBigEndian(_messageLength);

        ubyte[] data = h0 ~ h1;
        if (data.length < PACKET_HEADER_LENGTH)
        {
            ubyte[] h3 = new ubyte[PACKET_HEADER_LENGTH - data.length];
            return data ~ h3;
        }

        return data;
    }

    uint messageId()
    {
        return _messageID;
    }

    long messageLength()
    {
        return _messageLength;
    }

    uint extendLength()
    {
        return _extendLength;
    }

    override string toString() {
        return format("id: %d, length: %d  _extendLength: %d", _messageID, _messageLength,_extendLength);
    }
}
