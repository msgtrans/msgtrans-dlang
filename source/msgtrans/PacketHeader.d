module msgtrans.PacketHeader;

enum int ID_FIELD_LENGTH = uint.sizeof;
enum int LENGTH_FIELD_LENGTH = uint.sizeof;
enum int COMPRESSION_FIELD_LENGTH = byte.sizeof;
// enum int RESERVED_FILED_LENGTH = -;
enum int EXTENSION_FIELD_LENGTH = ushort.sizeof;
enum int PACKET_HEADER_LENGTH = 16;

import std.bitmanip;
import std.format;
import std.stdint;

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
        uint _messageID = 0; 

        // Message data length
        uint _messageLength = 0;

        // Serialization type including json, protobuf, msgpack, flatbuffers and more
        // ushort _serializationType = 0;

        // used encrypt algorithm, 0 is none
        // ushort _encryptType = 0;

        // used compaction algorithm, 0 is none
        // ushort _compactionType = 0;
    }

    this(uint id, uint length)
    {
        _messageID = id;
        _messageLength = length;
    }

    // 00 00 27 11 00 00 00 05 00 00 00 00 00 00 00 00 68 65 6C 6C 6F 
    static PacketHeader parse(ubyte[] data)
    {
        // if (data.length < PACKET_HEADER_LENGTH)
        // {
        //     return null;
        // }
        // NOTE: Byte ordering is big endian.

        ubyte[ID_FIELD_LENGTH] idBytes = data[0..ID_FIELD_LENGTH];
        uint id = bigEndianToNative!(uint)(idBytes);
        
        enum LengthStart = ID_FIELD_LENGTH;
        enum LengthEnd = ID_FIELD_LENGTH + LENGTH_FIELD_LENGTH;
        ubyte[LENGTH_FIELD_LENGTH] lengthBytes = data[LengthStart..LengthEnd];
        uint length = bigEndianToNative!uint(lengthBytes);

        return new PacketHeader(id, length);
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

    override string toString() {
        return format("id: %d, lenth: %d", _messageID, _messageLength);
    }
}
