module msgtrans.SessionManager;

import msgtrans.channel.TransportSession;

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
class SessionManager {
    private shared ulong _serverSessionId = 0;

    private {
        // List!(TransportSession)[uint] _sessions;
        TransportSession[ulong] _sessions;
        Mutex _locker;
    }

    this() {
        _locker = new Mutex();
    }

    package ulong genarateId() {
        return atomicOp!("+=")(_serverSessionId, 1);
    }

    TransportSession get(ulong id) {
        _locker.lock();
        scope(exit) _locker.unlock();
        return _sessions.get(id, null);
    }

    TransportSession[] get() {
        return _sessions.byValue.array();
    }

    TransportSession[] getByMessageId(uint messageId) {
        // auto itemPtr = messageId in _sessions;

        // if (itemPtr is null) {
        //     throw new NoSuchElementException();
        // }

        // return itemPtr.toArray();
        implementationMissing(false);
        return null;
    }

    void add(TransportSession session) {
        assert(session !is null);

        _locker.lock();
        scope(exit) _locker.unlock();
        _sessions[session.id()] = session;
        
        // uint messageId = session.messageId();
        // auto itemPtr = messageId in _sessions;
        // if(itemPtr is null) {
        //     _sessions[messageId] = new ArrayList!(TransportSession)(512);
        // }
        // _sessions[messageId].add(session);
    }

    void remove(ulong id) {
        _locker.lock();
        scope(exit) _locker.unlock();

        _sessions.remove(id);
    }

    void remove(TransportSession session) {
        assert(session !is null);

        remove(session.id());
        // _locker.lock();
        // scope(exit) _locker.unlock();

        // List!(TransportSession) sessions = _sessions.get(session.messageId(), null);
        // bool r = sessions.remove(session);
        // version(HUNT_DEBUG) {
        //     infof("Session removed: msgId=%d, id=%d", session.messageId(), session.id());
        // }
    }

    void clear() {
        _locker.lock();
        scope(exit) _locker.unlock();

        _sessions.clear();
    }

    bool exists(uint id) {
        auto itemPtr = id in _sessions;

        return itemPtr !is null;
    }
}
