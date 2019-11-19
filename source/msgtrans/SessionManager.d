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

module msgtrans.SessionManager;

import msgtrans.channel.TransportSession;

/** 
 * 
 */
interface SessionManager {

    ulong genarateId();

    TransportSession get(ulong id);

    TransportSession[] getAll();

    void add(TransportSession session);

    void remove(ulong id);

    void remove(TransportSession session);

    void clear();

    bool exists(uint id);
}
