module msgtrans.MessageTransportServer;

import msgtrans.channel.ServerChannel;
import msgtrans.SessionManager;

import msgtrans.Executor;
import hunt.logging.ConsoleLogger;

/** 
 * 
 */
class MessageTransportServer {

    ServerChannel[string] _tranportServers;
    SessionManager _manager;
    // Executor[string] executors;

    void addChannel(ServerChannel server) {
        string name = server.name();
        if(name in _tranportServers)
            throw new Exception("Server exists already: " ~ name);
        tracef("Adding server: %s", name);
        _tranportServers[name] = server;
    }

    SessionManager manager()
    {
        return _manager;
    }

    void start()
    {
        foreach(ServerChannel t; _tranportServers)
        {
            t.start();
        }
    }    
}