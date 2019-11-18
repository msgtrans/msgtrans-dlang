module msgtrans.channel.SessionManager;

import msgtrans.channel.TransportSession;

import hunt.Exceptions;

import core.atomic;
import core.sync.mutex;

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
        TransportSession[ulong] _sessions;
        Mutex _locker;
    }

    this() {
        _locker = new Mutex();
    }

    ulong genarateId() {
        return atomicOp!("+=")(_serverSessionId, 1);
    }

    TransportSession get(ulong id) {
        auto itemPtr = id in _sessions;

        if (itemPtr is null) {
            throw new NoSuchElementException();
        }

        return *itemPtr;
    }

    void add(TransportSession session) {
        assert(session !is null);

        _locker.lock();
        scope(exit) _locker.unlock();
        
        auto itemPtr = session.id() in _sessions;

    }

    bool exists(TransportSession session) {
        auto itemPtr = session.id() in _sessions;

        return itemPtr !is null;
    }
}
