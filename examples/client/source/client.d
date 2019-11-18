import std.stdio;

import msgtrans;

import message.Constants;
import message.HelloMessage;
import message.WelcomeMessage;

import hunt.logging;

import std.stdio : writeln;

void main()
{
    MessageTransportClient client = new MessageTransportClient();
    // client.transport(new TcpClientChannel("127.0.0.1", 9001));
    // client.transport(new TcpClientChannel("10.1.222.120", 9001));

    client.transport(new WebSocketClientChannel("127.0.0.1", 9002, "/test"));

    // client.transport(new WebsocketTransport("ws://msgtrans.huntlabs.net:9002/test"));

    // client.addExecutor(new MyExecutor);

    // client.codec(new CustomCodec).keepAlive().connect();

    // auto message = new HelloMessage;
    // message.name = "zoujiaqing";
    warning("sending message");
    client.send(MESSAGE.HELLO, "World");
    warning("waiting for response");

    getchar();
    client.close();
}


class MyExecutor : AbstractExecutor!(MyExecutor)
{
    this() {

    }

    @MessageId(MESSAGE.WELCOME)
    void welcome(TransportContext ctx, MessageBuffer buffer)
    {
        long msgId = buffer.id;
        string msg = cast(string) buffer.data;
        warningf("session %d, message: %s", ctx.session.id(), msg);

        // string welcome = "Welcome " ~ msg;
        // writeln(message.welcome);
    }
}