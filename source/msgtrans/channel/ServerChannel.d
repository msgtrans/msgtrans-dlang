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

module msgtrans.channel.ServerChannel;

import msgtrans.MessageTransport;
// import msgtrans.SessionManager;
import msgtrans.TransportContext;

/**
 *
 */
interface ServerChannel {
    string name();

    void start();

    void stop();

    // void setSessionManager(SessionManager manager);
    void set(MessageTransport transport);

    void onAccept(AcceptHandler handler);

    void onClose(CloseHandler handler);
}
