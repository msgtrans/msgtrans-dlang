module msgtrans.transport.tcp.TcpTransportSession;

import hunt.net;
import hunt.String;

import msgtrans.MessageBuffer;

import msgtrans.transport.TransportSession;

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

    // void onConnectionClosed() {
    //     _conn = null;
    // }

    override void sendMsg(MessageBuffer message) {
        if (_conn.isConnected()) {
            _conn.write(message);
        }
    }

    // override Connection getConnection() {
    //     return _conn;
    // }

    override void close() {
        if (_conn !is null && _conn.getState() !is ConnectionState.Closed) {
            _conn.close();
        }
    }

    override bool isConnected() {
        return _conn.isConnected();
    }
}
