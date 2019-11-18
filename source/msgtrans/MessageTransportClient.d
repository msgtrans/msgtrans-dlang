module msgtrans.MessageTransportClient;

import msgtrans.MessageTransport;
import msgtrans.MessageBuffer;
import msgtrans.channel.ClientChannel;

import hunt.logging.ConsoleLogger;

/** 
 * 
 */
class MessageTransportClient : MessageTransport {
    private bool _isConnected = false;
    private ClientChannel _channel;
    private string _name;

    this(string name) {
        _name = CLIENT_NAME_PREFIX ~ name;
    }

    void transport(ClientChannel channel) {
        assert(channel !is null);

        _channel = channel;
        _channel.connect();
        _isConnected = true;
    }

    void send(uint id, ubyte[] msg ) {
        // if(_channel.isConnected()) {

        // } else {
        //     warning("Connection broken!");
        // }
        _channel.send(new MessageBuffer(id, msg));
    }

    void send(uint id, string msg ) {
        this.send(id, cast(ubyte[]) msg);
    }

    string name() {
        return _name;
    }

    void close() {
        _channel.close();
    }
}