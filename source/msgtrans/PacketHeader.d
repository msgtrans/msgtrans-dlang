module msgtrans.Packet;

enum PACKET_HEADER_LENGTH = 32;

import std.stdint;
import std.bitmanip;

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

class PacketHeader
{
    private
    {
        // Message ID
        ulong _messageID = 0;

        // Message data length
        ulong _messageLength = 0;

        // Serialization type including json, protobuf, msgpack, flatbuffers and more
        // ushort _serializationType = 0;

        // used encrypt algorithm, 0 is none
        // ushort _encryptType = 0;

        // used compaction algorithm, 0 is none
        // ushort _compactionType = 0;
    }

    this(ulong id, ulong length)
    {
        _messageID = id;
        _messageLength = length;
    }

    static PacketHeader parse(ubyte[] bytes)
    {
        if (bytes.length < PACKET_HEADER_LENGTH)
        {
            return null;
        }

        ulong id = bigEndianToNative!ulong(bypes[0..7]);
        ulong length = bigEndianToNative!ulong(bypes[8..15]);

        return new PacketHeader(id, length);
    }

    ubyte[] data()
    {
        ubyte[8] h0 = nativeToBigEndian(_messageID);
        ubyte[8] h1 = nativeToBigEndian(_messageLength);

        ubyte data = h0 ~ h1;
        if (data.length < PACKET_HEADER_LENGTH)
        {
            ubyte[PACKET_HEADER_LENGTH - data.length] h3;
            return data ~ h3;
        }

        return data;
    }

    long messageId()
    {
        return _messageID;
    }

    long messageLength()
    {
        return _messageLength;
    }
}
