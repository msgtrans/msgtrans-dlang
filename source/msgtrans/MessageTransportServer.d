module msgtrans.MessageTransportServer;

import msgtrans.channel.ServerChannel;
import msgtrans.SessionManager;
import msgtrans.TransportContext;

import msgtrans.executor.Executor;
import hunt.logging.ConsoleLogger;


/** 
 * 
 */
class MessageTransportServer {

    private ContextHandler _acceptHandler;

    ServerChannel[string] _tranportServers;
    SessionManager _manager;

    this() {
        this(new SessionManager());
    }

    this(SessionManager manager) {
        _manager = manager;
    }

    void addChannel(ServerChannel server) {
        string name = server.name();
        if(name in _tranportServers)
            throw new Exception("Server exists already: " ~ name);
        tracef("Adding server: %s, type: %s", name, typeid(cast(Object)server));
        _tranportServers[name] = server;
    }

    void onAccept(ContextHandler handler) {
        _acceptHandler = handler;
    }

    SessionManager manager()
    {
        return _manager;
    }

    void start()
    {
        foreach(ServerChannel t; _tranportServers)
        {
            t.setSessionManager(_manager);
            t.setAcceptHandler(_acceptHandler);
            t.start();
        }
    }    
}