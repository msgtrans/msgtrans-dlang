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

module msgtrans.DefaultSessionManager;

import msgtrans.channel.TransportSession;
import msgtrans.SessionManager;

import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

import core.atomic;
import core.sync.mutex;
import std.array;

// private shared ulong _serverSessionId = 0;
private shared ulong _clientSessionId = 0;

// ulong nextServerSessionId() {
//     return atomicOp!("+=")(_serverSessionId, 1);
// }

ulong nextClientSessionId() {
    return atomicOp!("+=")(_clientSessionId, 1);
}

/**
 *
 */
class DefaultSessionManager : SessionManager {
    private shared ulong _serverSessionId = 0;

    private {
        TransportSession[ulong] _sessions;
        Mutex _locker;
    }

    this() {
        _locker = new Mutex();
    }

    ulong generateId() {
        return atomicOp!("+=")(_serverSessionId, 1);
    }

    TransportSession get(ulong id) {
        _locker.lock();
        scope (exit)
            _locker.unlock();
        return _sessions.get(id, null);
    }

    TransportSession[] getAll() {
        return _sessions.byValue.array();
    }

    void add(TransportSession session) {
        assert(session !is null);

        _locker.lock();
        scope (exit)
            _locker.unlock();
        _sessions[session.id()] = session;
    }

    void remove(ulong id) {
        _locker.lock();
        scope (exit)
            _locker.unlock();

        _sessions.remove(id);
    }

    void remove(TransportSession session) {
        assert(session !is null);

        remove(session.id());
    }

    void clear() {
        _locker.lock();
        scope (exit)
            _locker.unlock();

        _sessions.clear();
    }

    bool exists(uint id) {
        auto itemPtr = id in _sessions;

        return itemPtr !is null;
    }
}
