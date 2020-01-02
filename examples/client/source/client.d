import std.stdio;

import msgtrans;

import hunt.logging;
import hunt.util.Serialize;

void main()
{
    MessageTransportClient client = new MessageTransportClient("test");

    client.channel(new TcpClientChannel("127.0.0.1", 9001));

    string name = "zoujiaqing";

    auto buffer = new MessageBuffer;
    buffer.id = MESSAGE.HELLO;
    buffer.data = name.dup;

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
        auto welcomeText = cast(string) buffer.data;

        infof("message: %s", welcomeText);
    }
}
