import hunt.net;
import hunt.logging;

import msgtrans;

import message.Constants;
import message.HelloMessage;
import message.WelcomeMessage;

import core.thread;
import core.time : seconds;

import hunt.util.Serialize;

enum ServerName = "test";
enum ClientName = "test";


void main()
{
    MessageTransportServer server = new MessageTransportServer(ServerName);

    server.addChannel(new TcpServerChannel(9001));
    server.addChannel(new WebSocketServerChannel(9002, "/test"));

    server.acceptor((TransportContext ctx) {
        infof("New connection: id=%d", ctx.id());
    });

    server.closer((TransportSession session){
      infof("connection: id=%d closed", session.id());
    });

    server.start();
}

@TransportServer(ServerName)
@TransportClient(ClientName)
class MyExecutor : AbstractExecutor!(MyExecutor)
{

    @MessageId(MESSAGE.HELLO)
    void hello(TransportContext ctx, MessageBuffer buffer) {

        HelloMessage message = unserialize!HelloMessage(cast(const byte[])buffer.data);

        WelcomeMessage welcomeMessage = new WelcomeMessage;
        welcomeMessage.welcome = "Hello " ~ message.name;

        ctx.session().send(new MessageBuffer(MESSAGE.WELCOME, cast(ubyte[])serialize(welcomeMessage)));
    }
}
