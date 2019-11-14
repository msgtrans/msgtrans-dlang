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
    client.transport(new TcpClientChannel("127.0.0.1", 9001));
    // client.transport(new TcpClientChannel("10.1.222.120", 9001));

    // client.transport(new WebsocketTransport("ws://msgtrans.huntlabs.net:9002/test"));

    // client.addExecutor(new MyExecutor);

    // client.codec(new CustomCodec).keepAlive().connect();

    // auto message = new HelloMessage;
    // message.name = "zoujiaqing";

    client.send(MESSAGE.HELLO, "World");

    client.block();
}


class MyExecutor : AbstractMessageExecutor!(MyExecutor)
{
    this() {

    }

    @MessageId(MESSAGE.WELCOME)
    void welcome(TransportSession ctx, ubyte[] data)
    {
        string msg = cast(string) data;
        warningf("session %d, message: %s", ctx.id(), msg);

        // string welcome = "Welcome " ~ msg;
        // writeln(message.welcome);
    }
}