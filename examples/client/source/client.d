import msgtrans;

import hunt.logging;

void main()
{
    import std.stdio : getchar;

    MessageTransportClient client = new MessageTransportClient("test");

    client.channel(new TcpClientChannel("127.0.0.1", 9001));

    string name = "zoujiaqing";

    auto buffer = new MessageBuffer(MESSAGE.HELLO, name.dup);

    client.send(buffer);

    getchar();

    client.close();
}

enum MESSAGE : uint {
    HELLO = 10001,
    WELCOME = 20001
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
