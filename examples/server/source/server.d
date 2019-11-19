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


void main() {
    MessageTransportServer server = new MessageTransportServer(ServerName);

    server.addChannel(new TcpServerChannel(9001));
    // server.addChannel(new TcpServerChannel(9003));
    server.addChannel(new WebSocketServerChannel(9002, "/test"));

    server.onAccept((TransportContext ctx) {
        TransportSession session = ctx.session();
        infof("New connection: id=%d", session.id());
    });

    server.start(); // .codec(new CustomCodec) // .keepAliveAckTimeout(60.seconds)
}

/** 
 * 
 */
@TransportServer(ServerName)
@TransportClient(ClientName)
class MyExecutor : AbstractExecutor!(MyExecutor) {



    @MessageId(MESSAGE.HELLO)
    void hello(TransportContext ctx, MessageBuffer buffer) {

        TransportSession session = ctx.session();
        // HelloMessage message = unserialize!HelloMessage(cast(const byte[])buffer.data);
        // WelcomeMessage welcomeMessage = new WelcomeMessage;
        // welcomeMessage.welcome = "Hello " ~ message.name;

        // warningf("session %d, message: %s", ctx.id(), welcomeMessage.welcome);

        // ctx.send(new MessageBuffer(MESSAGE.WELCOME, cast(ubyte[])serialize(welcomeMessage)));

        warningf("session %d, message: %s", session.id(), buffer.toString());

        // list avaliable sessions
        SessionManager sessionManager = ctx.sessionManager();
        TransportSession[] sessions = sessionManager.getAll();

        foreach (TransportSession s; sessions) {
            tracef("session %d", s.id);
        }

        // response
        string welcome = "Hello " ~ cast(string) buffer.data;
        session.send(MESSAGE.WELCOME, welcome);
    }

}
