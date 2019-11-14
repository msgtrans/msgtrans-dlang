module msgtrans.transport.TransportSession;

import msgtrans.MessageBuffer;
import msgtrans.Router;
import msgtrans.ParserBase;
import msgtrans.Command;

import hunt.util.Serialize;
import hunt.net;
import hunt.logging;

import core.atomic;
import std.stdint;
import std.bitmanip;

private shared long _serverSessionId = 0;
private shared long _clientSessionId = 0;

long nextServerSessionId() {
    return atomicOp!("+=")(_serverSessionId, 1);
}

long nextClientSessionId() {
    return atomicOp!("+=")(_clientSessionId, 1);
}

/** 
 * 
 */
abstract class TransportSession {

    private long _id;

    this(long id) {
        _id = id;
    }

    long id() {
        return _id;
    }

    Object getAttribute(string key);

    void setAttribute(string key, Object value);
    
    bool containsAttribute(string key);


    void send(uint messageId, string content) {
        sendMsg(new MessageBuffer(messageId, cast(ubyte[])content));
    }

    void sendMsg(MessageBuffer message);

    // abstract Connection getConnection() {
    //     return _connection;
    // }

    void close();

    bool isConnected();
}
