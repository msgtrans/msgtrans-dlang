module msgtrans.channel.TransportSession;

import msgtrans.MessageBuffer;
import msgtrans.channel.SessionManager;

import hunt.util.Serialize;
import hunt.net;
import hunt.logging;

import core.atomic;
import std.stdint;
import std.bitmanip;



/** 
 * 
 */
abstract class TransportSession {

    private
    {
        ulong _id;
        // SessionManager _sessionManager;
    }
    
    // this(SessionManager sessionManager) {
    //     _id = sessionManager.genarateId();
    //     _sessionManager = sessionManager;
    // }
    this(ulong id) {
        _id = id;
        // _id = sessionManager.genarateId();
        // _sessionManager = sessionManager;
    }

    ulong id() {
        return _id;
    }

    // SessionManager sessionManager()
    // {
    //     return _sessionManager;
    // }

    Object getAttribute(string key);

    void setAttribute(string key, Object value);
    
    bool containsAttribute(string key);

    void send(MessageBuffer buffer);

    void send(uint messageId, string content) {
        send(new MessageBuffer(messageId, cast(ubyte[])content));
    }


    // abstract Connection getConnection() {
    //     return _connection;
    // }

    void close();

    bool isConnected();
}
