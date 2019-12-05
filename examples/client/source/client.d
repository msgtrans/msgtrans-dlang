import std.stdio;

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
    buffer.data = cast(ubyte[]) serialize(message);

    client.send(buffer);

    getchar();
    client.close();
}

@TransportClient("test")
class MyExecutor : AbstractExecutor!(MyExecutor)
{
    this()
    {

    }

    @MessageId(MESSAGE.WELCOME)
    void welcome(TransportContext ctx, MessageBuffer buffer)
    {
        auto message = unserialize!WelcomeMessage(cast(byte[]) buffer.data);

        infof("message: %s", message.welcome);
    }
}
