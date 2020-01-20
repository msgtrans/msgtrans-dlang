# MsgTrans for DLang
Message Transport Framework. Based on TCP, WebSocket, UDP transmission protocol.

## Create a Message Transport Server using msgtrans
```D
import msgtrans;

import hunt.logging;

void main()
{
    MessageTransportServer server = new MessageTransportServer("test");

    server.addChannel(new TcpServerChannel(9001));
    server.addChannel(new WebSocketServerChannel(9002, "/ws"));

    server.acceptor((TransportContext ctx) {
        infof("New connection: id=%d", ctx.id());
    });

    server.start();
}

@TransportServer("test")
@TransportClient("test")
class MyExecutor : AbstractExecutor!(MyExecutor)
{

    @MessageId(MESSAGE.HELLO)
    void hello(TransportContext ctx, MessageBuffer buffer)
    {

        string name = cast(string) buffer.data;

        string welcomeText = "Hello " ~ name;

        ctx.send(new MessageBuffer(MESSAGE.WELCOME, cast(ubyte[]) welcomeText));
    }
}
```

## Create a Client connect to Server
```D
import msgtrans;

import hunt.logging;

void main()
{
    MessageTransportClient client = new MessageTransportClient("test");

    client.channel(new TcpClientChannel("127.0.0.1", 9001)).connect();

    string name = "zoujiaqing";

    auto buffer = new MessageBuffer(MESSAGE.HELLO, name.dup);

    client.send(buffer);

    getchar();
    client.close();
}

@TransportClient("test")
class MyExecutor : AbstractExecutor!(MyExecutor)
{
    @MessageId(MESSAGE.WELCOME)
    void welcome(TransportContext ctx, MessageBuffer buffer)
    {
        auto message = unserialize!WelcomeMessage(buffer.data);

        infof("message: %s", message.welcome);
    }
}
```
