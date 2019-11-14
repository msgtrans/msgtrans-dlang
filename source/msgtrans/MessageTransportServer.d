module msgtrans.MessageTransportServer;

import msgtrans.transport.ServerChannel;

import msgtrans.MessageExecutor;
import hunt.logging.ConsoleLogger;

/** 
 * 
 */
class MessageTransportServer {

    ServerChannel[string] _tranportServers;
    // MessageExecutor[string] executors;
    

    void addChannel(ServerChannel server) {
        string name = server.name();
        if(name in _tranportServers)
            throw new Exception("Server exists already: " ~ name);
        tracef("Adding server: %s", name);
        _tranportServers[name] = server;
    }

    // void registerExecutor(T)() if(is(T : MessageExecutor)) {

    // }


    void start()
    {
        foreach(ServerChannel t; _tranportServers)
        {
            // NetServer server = NetUtil.createNetServer();
            // server.setCodec(t.getCodec());
            // server.setHandler(protocol.getHandler());
            // if (protocol.getOptions() !is null)
            // {
            //     server.setOptions(protocol.getOptions());
            // }
            // server.listen(t.getHost() ,t.getPort());

            // _netServers[t.getName()] = server;
            t.start();
        }
    }    
}