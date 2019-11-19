import std.stdio;

import msgtrans;

import message.Constants;
import message.HelloMessage;
import message.WelcomeMessage;

import hunt.logging;

import std.stdio : writeln;

enum string ClientName = "test";

void main()
{
    MessageTransportClient client = new MessageTransportClient(ClientName);

    // TCP channel
    // client.transport(new TcpClientChannel("127.0.0.1", 9001));
    // client.transport(new TcpClientChannel("10.1.222.120", 9001));

    // WebSocket channel
    // client.transport(new WebSocketClientChannel("127.0.0.1", 9002, "/test"));
    client.transport(new WebSocketClientChannel("ws://127.0.0.1:9002/test"));

    // auto message = new HelloMessage;
    warning("sending message");
    client.send(MESSAGE.HELLO, "World");
    warning("waiting for response");

    getchar();
    client.close();
}

/** 
 * 
 */

@MessageClient(ClientName)
class MyExecutor : AbstractExecutor!(MyExecutor)
{
    this()
    {

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
