module msgtrans.MessageTransportFactory;

// import hunt.net;

// import msgtrans.ConnectionEventBaseHandler;
// import msgtrans.ConnectionManager;

// import msgtrans.channel.ServerChannel;
// import msgtrans.channel.TransportClient;

// import std.typecons;

// class MessageTransportFectory
// {
//     private
//     {
//         this () {
//         }
//     }

//    static MessageTransportClientFectory client()
//    {
//        return new MessageTransportClientFectory;
//    }

//    static MessageTransportClientFectory server()
//    {
//        return new MessageTransportServerFectory;
//    }

//    interface MessageTransportInterface
//    {
//        MessageTransportInterface start();
//        MessageTransportInterface block();
//    }

//    class MessageTransportClientFectory : MessageTransportInterface
//    {
//        private
//        {
//            TransportClient _client;
//        }

//        MessageTransportClientFectory connect()
//        {
//            // TODO
//        }

//        MessageTransportClientFectory transport(TransportClient client)
//        {
//            _client = client;
//        }
//    }

//    class MessageTransportServerFectory : MessageTransportInterface
//    {
//        private
//        {
//            ServerChannel[string] _servers;
//        }

//        MessageTransportServerFectory addTransport(ServerChannel server)
//        {
//            _servers[server.name()] = server;
//            return this;
//        }

//        MessageTransportServerFectory start()
//        {
//            foreach (server; _servers)
//            {
//                server.start();
//            }
//        }
//    }
// }
