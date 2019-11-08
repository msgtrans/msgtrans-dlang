module msgtrans.Packet;

import hunt.logging;
import hunt.util.Serialize;

import msgtrans.PacketHeader;

class Packet
{
    static PacketHeader parseHeader(ubyte[] data)
    {
        if (data.length > PACKET_HEADER_LENGTH)
        {
            auto header = new PacketHeader;
            if (header.parse(data[0..31]))
            {
                return header;
            }
        }
        
        return null;
    }

    static ubyte[] encode(ulong messageId, ubyte[] data)
    {
        auto header = new PacketHeader(messageId, data.length);

        return header.data() ~ message;
    }

    static MessageBuffer decode(ubyte[] data)
    {
        if (data.length >= PACKET_HEADER_LENGTH)
        {
            auto header = new PacketHeader;
            header.parse(data[0..31]);

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
