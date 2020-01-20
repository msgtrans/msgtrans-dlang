import msgtrans;

import hunt.logging;

enum ServerName = "test";
enum ClientName = "test";

void main()
{
    MessageTransportServer server = new MessageTransportServer(ServerName);

    server.addChannel(new TcpServerChannel(9001));
    server.addChannel(new WebSocketServerChannel(9002, "/ws"));

    server.acceptor((TransportContext ctx) {
        infof("New connection: id=%d", ctx.id());
    });

    server.closer((TransportContext ctx){
      infof("connection: id=%d closed", ctx.id());
    });

    server.start();
}

enum MESSAGE : uint {
    HELLO = 10001,
    WELCOME = 20001
}

@TransportServer(ServerName)
@TransportClient(ClientName)
class MyExecutor : AbstractExecutor!(MyExecutor)
{

    @MessageId(MESSAGE.HELLO)
    void hello(TransportContext ctx, MessageBuffer buffer) {

        string name = cast(string) buffer.data;

        WelcomeMessage welcomeText = "Hello " ~ name;

        ctx.session().send(new MessageBuffer(MESSAGE.WELCOME, welcomeText.dup));
    }
}
