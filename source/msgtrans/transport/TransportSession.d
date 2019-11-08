module msgtrans.Session;

import msgtrans.MessageBuffer;
import msgtrans.Router;
import msgtrans.ParserBase;
import msgtrans.Command;

import hunt.util.Serialize;
import hunt.net;
import hunt.logging;

import google.protobuf;

import std.stdint;
import std.bitmanip;

enum SESSION
{
    PROTOCOL = "PROTOCOL",
    USER = "USER"
}

class TransportSession {

public:
    static void dispatchMessage(Session connection , MessageBuffer message )
    {
        Command handler =  Router.instance().getProcessHandler(message.messageId);
        if (handler !is null)
        {
            handler.execute(connection,message);
        } else {
            logError("Unknown msgType %d",message.messageId );
        }
    }

    abstract void sendMsg(MessageBuffer message) {}

    abstract string getProtocol() { return null;}

    abstract Connection getConnection() {return null;}

    abstract void close() {}

    abstract bool isConnected() {return false;}
}
