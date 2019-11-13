module msgtrans.PacketParser;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.collection.List;
import hunt.collection.ArrayList;

// import hunt.collection.StringBuffer;

import hunt.logging.ConsoleLogger;
import hunt.util.Serialize;

import msgtrans.MessageBuffer;
import msgtrans.PacketHeader;

class Packet
{
    static PacketHeader parseHeader(ubyte[] data)
    {
        if (data.length > PACKET_HEADER_LENGTH)
        {
            return PacketHeader.parse(data);
        }
        
        return null;
    }

    static ubyte[] encode(ulong messageId, ubyte[] data)
    {
        auto header = new PacketHeader(messageId, data.length);

        return header.data() ~ data;
    }

    static MessageBuffer decode(ubyte[] data)
    {
        if (data.length >= PACKET_HEADER_LENGTH)
        {
            PacketHeader header = PacketHeader.parse(data);

            if (data.length != (header.messageLength + PACKET_HEADER_LENGTH))
            {
                // packet error
                logError("The message data is corrupted.");
                return null;
            }

            return new MessageBuffer(header.messageId(), data[PACKET_HEADER_LENGTH..$]);
        } else
            return null;
    }
}


class PacketParser {
    private ByteBuffer _buffer;


    this(size_t length = 8*1024) {
        // _buffer = new ArrayList!ByteBuffer(10);
        _buffer = BufferUtils.allocate(length);
    }

    MessageBuffer[] parse(ByteBuffer buffer) {
        // TODO: Tasks pending completion -@zhangxueping at 2019-11-13T10:07:54+08:00
        // buffer the remaining and try to parse more message packets

        tracef("remaining: %d", buffer.remaining());
        

        while (buffer.remaining() >= PACKET_HEADER_LENGTH)
        {
            ubyte[] data = cast(ubyte[])buffer.getRemaining();
            PacketHeader header = PacketHeader.parse(data);
            infof("packet header, %s", header.toString());


            if (data.length != (header.messageLength + PACKET_HEADER_LENGTH))
            {
                // packet error
                logError("The message data is corrupted.");
                return null;
            }

            return [new MessageBuffer(header.messageId(), data[PACKET_HEADER_LENGTH..$])];
        } 
        
        if(buffer.remaining() > 0) {
            _buffer.put(buffer); // buffer the remaining
        }
        
        return null;
    }
}