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

module msgtrans.channel.tcp.TcpEncoder;

import hunt.net.codec.Encoder;
import hunt.net.Connection;

import msgtrans.MessageBuffer;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;

import std.bitmanip;
import std.conv;
import std.stdio;
import std.stdint;

class TcpEncoder : Encoder {

   override void encode(Object message, Connection connection)
   {
    //    auto msg = cast(MessageBuffer)message;
    //    ubyte[] msgBody = msg.message;

    //    if (msgBody.length > 2147483647 || msgBody.length < 0 )
    //    {
    //        return;
    //    }

    //    ubyte[8] u1 = nativeToBigEndian(msg.authId);
    //    ubyte[8] u2 = nativeToBigEndian(msg.messageId);
    //    ubyte[4] u3 = nativeToBigEndian(cast(int32_t)msgBody.length);

    //    connection.write(u1 ~ u2 ~ u3 ~ msgBody);
   }

    void setBufferSize(int size)
    {

    }
}
