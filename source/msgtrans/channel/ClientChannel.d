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

module msgtrans.channel.ClientChannel;

import msgtrans.MessageBuffer;
import msgtrans.MessageTransport;
import msgtrans.TransportContext;

// import hunt.net;

interface ClientChannel
{
    void connect();

    bool isConnected();

    void set(MessageTransport transport);

    void send(MessageBuffer buffer);

    void close();

    void onClose(CloseHandler handler);
}
