# MsgTrans for DLang
Message Transport Framework. Based on TCP, WebSocket, UDP transmission protocol.

## Create a Message Transport Server using msgtrans
```D
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
    MessageTransportServer server = new MessageTransportServer("test");

    server.addChannel(new TcpServerChannel(9001));
    server.addChannel(new WebSocketServerChannel(9002, "/test"));

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
    void hello(TransportContext ctx, MessageBuffer buffer) {

        HelloMessage message = unserialize!HelloMessage(cast(const byte[])buffer.data);

        WelcomeMessage welcomeMessage = new WelcomeMessage;
        welcomeMessage.welcome = "Hello " ~ message.name;

        ctx.send(new MessageBuffer(MESSAGE.WELCOME, cast(ubyte[])serialize(welcomeMessage)));
    }
}
```

## Create a Client connect to Server
```D
import msgtrans;

import message.Constants;
import message.HelloMessage;
import message.WelcomeMessage;

import hunt.logging;
import hunt.util.Serialize;

void main()
{
    MessageTransportClient client = new MessageTransportClient("test");

    client.transport(new TcpClientChannel("127.0.0.1", 9001));

    auto message = new HelloMessage;
    message.name = "zoujiaqing";

    auto buffer = new MessageBuffer;
    buffer.id = MESSAGE.HELLO;
    buffer.data = serialize(message);

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
