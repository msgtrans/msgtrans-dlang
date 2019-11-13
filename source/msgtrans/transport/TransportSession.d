module msgtrans.transport.TransportSession;

import msgtrans.MessageBuffer;
import msgtrans.Router;
import msgtrans.ParserBase;
import msgtrans.Command;

import hunt.util.Serialize;
import hunt.net;
import hunt.logging;


import std.stdint;
import std.bitmanip;

abstract class TransportSession {

    private
    {
        long _id;
    }
    
    abstract long id() { return 0; }

    abstract void sendMsg(MessageBuffer message) {}

    // abstract string getProtocol() { return null;}

    abstract Connection getConnection() {return null;}

    abstract void close() {}

    abstract bool isConnected() {return false;}
}
