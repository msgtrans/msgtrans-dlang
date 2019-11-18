module msgtrans.MessageTransportServer;

import msgtrans.channel.ServerChannel;
import msgtrans.SessionManager;
import msgtrans.DefaultSessionManager;
import msgtrans.TransportContext;
import msgtrans.MessageTransport;
import msgtrans.executor.Executor;

import hunt.logging.ConsoleLogger;

__gshared MessageTransportServer[string] messageTransportServers;

/** 
 * 
 */
class MessageTransportServer : MessageTransport {


    private string _name;
    private ContextHandler _acceptHandler;

    ServerChannel[string] _tranportServers;
    SessionManager _manager;

    this(string name)
    {
        _name = SERVER_NAME_PREFIX ~ name;
    }

    string name()
    {
        return _name;
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

    MessageTransportServer setSessionManager(SessionManager manager)
    {
        _manager = manager;

        return this;
    }

    SessionManager manager()
    {
        if (_manager is null)
        {
            _manager = new DefaultSessionManager();
        }

        return _manager;
    }

    void start()
    {
        foreach(ServerChannel t; _tranportServers)
        {
            t.setSessionManager(this.manager());
            t.setAcceptHandler(_acceptHandler);
            t.start();
        }
    }    
}
