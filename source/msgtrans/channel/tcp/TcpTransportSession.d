module msgtrans.channel.tcp.TcpTransportSession;

import msgtrans.Packet;
import msgtrans.MessageBuffer;
import msgtrans.channel.TransportSession;

import hunt.net;
import hunt.String;

import std.stdio;
import std.array;

/** 
 * 
 */
class TcpTransportSession : TransportSession {
    private Connection _conn = null;

    this(long id, Connection connection) {
        _conn = connection;
        super(id);
    }


    override Object getAttribute(string key) {
        return _conn.getAttribute(key);
    }

    override void setAttribute(string key, Object value) {
        _conn.setAttribute(key, value);
    }

    override bool containsAttribute(string key) {
        return _conn.containsAttribute(key);
    }


    override void send(MessageBuffer message) {
        if (_conn.isConnected()) {
            ubyte[][] buffers = Packet.encode(message);
            foreach(ubyte[] data; buffers) {
                _conn.write(data);
            }
        }
    }

    override void close() {
        if (_conn !is null && _conn.getState() !is ConnectionState.Closed) {
            _conn.close();
        }
    }

    override bool isConnected() {
        return _conn.isConnected();
    }
}
