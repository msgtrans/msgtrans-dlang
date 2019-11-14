module msgtrans.Packet;

import msgtrans.MessageBuffer;
import msgtrans.PacketHeader;

/** 
 * 
 */
class Packet
{
    // static ubyte[] encode(uint messageId, ubyte[] data)
    // {
    //     auto header = new PacketHeader(messageId, cast(uint)data.length);

    //     return header.data() ~ data;
    // }

    static ubyte[][] encode(MessageBuffer message) {
        ubyte[] header = PacketHeader.encode(message.id, cast(uint)message.data.length);
        if(message.data.length < 1024) {
            return [header ~ message.data];
        } else {
            return [header, message.data];
        }
    }

    // static MessageBuffer decode(ubyte[] data)
    // {
    //     if (data.length >= PACKET_HEADER_LENGTH)
    //     {
    //         PacketHeader header = PacketHeader.parse(data);

    //         if (data.length != (header.messageLength + PACKET_HEADER_LENGTH))
    //         {
    //             // packet error
    //             logError("The message data is corrupted.");
    //             return null;
    //         }

    //         return new MessageBuffer(header.messageId(), data[PACKET_HEADER_LENGTH..$]);
    //     } else
    //         return null;
    // }
}
