module msgtrans.channel.websocket.WebSocketTransportSession;

import msgtrans.channel.TransportSession;
import msgtrans.MessageBuffer;
import msgtrans.Packet;

import hunt.http.WebSocketConnection;
import hunt.logging.ConsoleLogger;
import hunt.net;

/** 
 * 
 */
class WebsocketTransportSession : TransportSession {
    private WebSocketConnection _conn = null;

    this(long id, uint messageId, WebSocketConnection connection) {
        _conn = connection;
        super(id, messageId);
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
        warningf("isConnected: %s", _conn.isConnected());
        if (_conn.isConnected()) {
            ubyte[][] buffers = Packet.encode(message);
            foreach(ubyte[] data; buffers) {
                _conn.sendData(cast(byte[])data);
            }
        }
    }

    override void close() {
        if (_conn !is null && _conn.getIOState().isOpen()) {
            _conn.close();
        }
    }

    override bool isConnected() {
        return _conn.isConnected();
    }
}
