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

    server.addChannel(new TcpServerChannel(9001));
    // server.addChannel(new TcpServerChannel(9003));
    // server.addChannel(new WebsocketTransport(9002, "/test"));

    server.registerExecutor!MyExecutor();

    server.start();	 // .codec(new CustomCodec) // .keepAliveAckTimeout(60.seconds)
}


class MyExecutor : AbstractMessageExecutor!(MyExecutor)
{
    this() {

    }

    @MessageId(MESSAGE.HELLO)
    void hello(TransportSession ctx, ubyte[] data)
    {
        string msg = cast(string) data;

        string welcome = "Welcome " ~ msg;

        warningf("session %d, message: %s", ctx.id(), welcome);

        ctx.send(MESSAGE.WELCOME, welcome);
    }
}


class MyExecutor1 : AbstractMessageExecutor!(MyExecutor1) {

    this() {

    }
    
    @MessageId(MESSAGE.HELLO)
    void sayHello(TransportSession ctx, string msg)
    {
        string welcome = "Welcome " ~ msg;

        // ctx.send(MESSAGE.WELCOME, welcome.dup);
    }
}