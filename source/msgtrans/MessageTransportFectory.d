module msgtrans.MessageTransportFectory;

import hunt.net;

import msgtrans.ConnectionEventBaseHandler;
import msgtrans.ConnectionManager;

import msgtrans.transport.TransportServer;
import msgtrans.transport.TransportClient;

import std.typecons;

class MessageTransportFectory
{
    private
    {
        this () {
        }
    }

   static MessageTransportClientFectory client()
   {
       return new MessageTransportClientFectory;
   }

   static MessageTransportClientFectory server()
   {
       return new MessageTransportServerFectory;
   }

   interface MessageTransportInterface
   {
       MessageTransportInterface start();
       MessageTransportInterface block();
   }

   class MessageTransportClientFectory : MessageTransportInterface
   {
       private
       {
           TransportClient _client;
       }

       MessageTransportClientFectory connect()
       {
           // TODO
       }

       MessageTransportClientFectory transport(TransportClient client)
       {
           _client = client;
       }
   }

   class MessageTransportServerFectory : MessageTransportInterface
   {
       private
       {
           TransportServer[string] _servers;
       }

       MessageTransportServerFectory addTransport(TransportServer server)
       {
           _servers[server.name()] = server;
           return this;
       }

       MessageTransportServerFectory start()
       {
           foreach (server; _servers)
           {
               server.start();
           }
       }
   }
}
