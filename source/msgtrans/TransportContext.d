module msgtrans.TransportContext;

import msgtrans.SessionManager;
import msgtrans.DefaultSessionManager;
import msgtrans.channel.TransportSession;


alias ContextHandler = void delegate(TransportContext);

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

    ulong id()
    {
        return session().id();
    }
}
