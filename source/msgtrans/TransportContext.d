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

module msgtrans.TransportContext;

import msgtrans.SessionManager;
import msgtrans.DefaultSessionManager;
import msgtrans.channel.TransportSession;

alias AcceptHandler = void delegate(TransportContext);
alias CloseHandler = void delegate(TransportSession);

/**
 *
 */
struct TransportContext {
    private SessionManager _manager;
    private TransportSession _currentSession;

    SessionManager sessionManager() {
        return _manager;
    }

    TransportSession session() {
        return _currentSession;
    }

    ulong id() {
        return session().id();
    }
}
