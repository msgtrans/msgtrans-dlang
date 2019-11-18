module msgtrans.channel.SessionManager;

import msgtrans.channel.TransportSession;

import hunt.collection.List;
import hunt.collection.ArrayList;
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
        List!(TransportSession)[uint] _sessions;
        Mutex _locker;
    }

    this() {
        _locker = new Mutex();
    }

    ulong genarateId() {
        return atomicOp!("+=")(_serverSessionId, 1);
    }

    TransportSession[] get(uint messageId) {
        auto itemPtr = messageId in _sessions;

        if (itemPtr is null) {
            throw new NoSuchElementException();
        }

        return itemPtr.toArray();
    }

    void add(TransportSession session) {
        assert(session !is null);

        _locker.lock();
        scope(exit) _locker.unlock();
        
        uint messageId = session.messageId();
        auto itemPtr = messageId in _sessions;
        if(itemPtr is null) {
            _sessions[messageId] = new ArrayList!(TransportSession)(512);
        }
        _sessions[messageId].add(session);
    }

    bool exists(uint messageId) {
        auto itemPtr = messageId in _sessions;

        return itemPtr !is null;
    }
}
