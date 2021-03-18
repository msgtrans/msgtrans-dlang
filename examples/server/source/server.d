import msgtrans;

import hunt.logging;

enum ServerName = "test";
enum ClientName = "test";

enum TcpChannelPort = 9101;
enum WsChannelPort = 9102;

void main()
{
    MessageTransportServer server = new MessageTransportServer(ServerName);

    server.addChannel(new TcpServerChannel(TcpChannelPort));
    server.addChannel(new WebSocketServerChannel(WsChannelPort, "/ws"));

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
class MyExecutor : AbstractExecutor!(MyExecutor)
{

    @MessageId(MESSAGE.HELLO)
    void hello(TransportContext ctx, MessageBuffer buffer) {

        string name = cast(string) buffer.data;
        string welcomeText = "Hello " ~ name;

        ctx.session().send(new MessageBuffer(MESSAGE.WELCOME, welcomeText));
    }
}
