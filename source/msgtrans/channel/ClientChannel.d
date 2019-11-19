module msgtrans.channel.ClientChannel;

import msgtrans.MessageBuffer;
import msgtrans.MessageTransport;

// import hunt.net;

interface ClientChannel {

    void connect();

    bool isConnected();

    void set(MessageTransport transport);

    void send(MessageBuffer buffer);

    void close();

}
