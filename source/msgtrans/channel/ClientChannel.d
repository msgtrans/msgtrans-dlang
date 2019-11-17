module msgtrans.channel.ClientChannel;

import msgtrans.MessageBuffer;
import hunt.net;

interface ClientChannel {

    void connect();

    bool isConnected();

    void send(MessageBuffer buffer);

    void close();

}
