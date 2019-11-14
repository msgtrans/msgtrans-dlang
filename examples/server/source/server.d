import hunt.net;
import hunt.logging;

import msgtrans;
import message.Constants;
import message.HelloMessage;
import message.WelcomeMessage;

import core.thread;
import core.time : seconds;

import hunt.util.Serialize;

void main()
{
    MessageTransportServer server = new MessageTransportServer();

    server.addChannel(new TcpServerChannel(9001));
    // server.addChannel(new TcpServerChannel(9003));
    // server.addChannel(new WebsocketTransport(9002, "/test"));

    server.start();	 // .codec(new CustomCodec) // .keepAliveAckTimeout(60.seconds)
}


class MyExecutor : AbstractExecutor!(MyExecutor)
{
    this() {
    }

    @MessageId(MESSAGE.HELLO)
    void hello(TransportSession ctx, MessageBuffer buffer)
    {
        HelloMessage message = unserialize!HelloMessage(cast(const byte[])buffer.data);
        WelcomeMessage welcomeMessage = new WelcomeMessage;
        welcomeMessage.welcome = "Hello " ~ message.name;

        warningf("session %d, message: %s", ctx.id(), welcomeMessage.welcome);

        ctx.send(new MessageBuffer(MESSAGE.WELCOME, cast(ubyte[])serialize(welcomeMessage)));
    }
}


// class MyExecutor1 : AbstractExecutor!(MyExecutor1) {

//     this() {

//     }
    
//     @MessageId(MESSAGE.HELLO)
//     void sayHello(TransportSession ctx, string msg)
//     {
//         string welcome = "Welcome " ~ msg;

//         // ctx.send(MESSAGE.WELCOME, welcome.dup);
//     }
// }