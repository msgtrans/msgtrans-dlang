module msgtrans.MessageTransportClient;

import msgtrans.MessageBuffer;
import msgtrans.transport.ClientChannel;

import hunt.logging.ConsoleLogger;

/** 
 * 
 */
class MessageTransportClient {
    private bool _isConnected = false;
    private ClientChannel _channel;

    this() {

    }

    void transport(ClientChannel channel) {
        assert(channel !is null);

        _channel = channel;
        _channel.connect();
        _isConnected = true;
        // try {
        // } catch(Exception ex) {
        //     debug warningf(ex.msg);
        //     version(HUNT_DEBUG) warning(ex);
        //     _channel.close();
        // }
    }

    void send(uint id, string msg ) {
        // if(_channel.isConnected()) {

        // } else {
        //     warning("Connection broken!");
        // }
        _channel.send(new MessageBuffer(id, cast(ubyte[])msg));
    }

    void block() {

    }
}