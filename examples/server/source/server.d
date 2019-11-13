import hunt.net;
import hunt.logging;

import msgtrans;
import message.Constants;
import message.HelloMessage;
import message.WelcomeMessage;

import core.thread;
import core.time : seconds;


void main()
{
    MessageTransportServer server = new MessageTransportServer();

    server.addChannel(new TcpTransportServer(9001));
    // server.addChannel(new TcpTransportServer(9003));
    // server.addChannel(new WebsocketTransport(9002, "/test"));

    server.registerExecutor!MyExecutor();

    server.start();	 // .codec(new CustomCodec) // .keepAliveAckTimeout(60.seconds)
}


class MyExecutor : MessageExecutor
{
    @MessageId(MESSAGE.HELLO)
    void hello(TransportSession ctx, ubyte[] data)
    {
        string msg = cast(string) data;

        string welcome = "Welcome " ~ msg;

        // ctx.send(MESSAGE.WELCOME, welcome.dup);
    }
}