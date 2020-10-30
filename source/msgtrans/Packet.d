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

module msgtrans.Packet;

import msgtrans.MessageBuffer;
import msgtrans.PacketHeader;
import hunt.logging;
import std.bitmanip;
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
        ubyte[] header = PacketHeader.encode(message);
        if (message.extendLength > 0)
        {
            ubyte[4] extend = nativeToBigEndian(message.tagId);
            if(message.data.length < 1024) {
              return [header ~ extend.dup ~ message.data];
            } else {
              return [header , extend.dup, message.data];
            }
        }else
        {
          if(message.data.length < 1024) {
            return [header ~ message.data];
          } else {
            return [header ,message.data];
          }
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
