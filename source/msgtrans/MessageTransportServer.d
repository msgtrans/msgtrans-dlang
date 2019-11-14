module msgtrans.MessageTransportServer;

import msgtrans.transport.ServerChannel;

import msgtrans.Executor;
import hunt.logging.ConsoleLogger;

/** 
 * 
 */
class MessageTransportServer {

    ServerChannel[string] _tranportServers;
    // Executor[string] executors;

    void addChannel(ServerChannel server) {
        string name = server.name();
        if(name in _tranportServers)
            throw new Exception("Server exists already: " ~ name);
        tracef("Adding server: %s", name);
        _tranportServers[name] = server;
    }

    void start()
    {
        foreach(ServerChannel t; _tranportServers)
        {
            t.start();
        }
    }    
}