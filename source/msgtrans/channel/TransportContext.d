module msgtrans.channel.TransportContext;

import msgtrans.SessionManager;
import msgtrans.channel.TransportSession;

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
}
