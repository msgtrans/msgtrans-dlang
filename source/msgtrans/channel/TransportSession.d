module msgtrans.channel.TransportSession;

import msgtrans.MessageBuffer;
import msgtrans.SessionManager;

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
        uint _messageId;
    }
    
    this(ulong id, uint messageId) {
        _id = id;
        _messageId = messageId;
    }

    ulong id() {
        return _id;
    }

    uint messageId() {
        return _messageId;
    }

    void messageId(uint id) {
        _messageId = id;
    }

    Object getAttribute(string key);

    void setAttribute(string key, Object value);
    
    bool containsAttribute(string key);

    void send(MessageBuffer buffer);

    void send(uint messageId, string content) {
        send(new MessageBuffer(messageId, cast(ubyte[])content));
    }

    void close();

    bool isConnected();
}
