module command.SayHelloCommand;

import msgtrans.Command;
import msgtrans.Session;
import msgtrans.MessageBuffer;
import common.helloworld;
import hunt.net;
import common.Commands;
import msgtrans.Router;
import google.protobuf;
import hunt.logging;
import std.array;

class SayHelloCommand : Command {

    void execute (Session connection,MessageBuffer msg)
    {
        auto req = new HelloRequest();
        msg.message.fromProtobuf!HelloRequest(req);

        auto resp = new HelloReply();
        resp.message = "hello " ~ req.name;
        MessageBuffer answer = new MessageBuffer(Commands.SayHelloResp,resp.toProtobuf.array);
        connection.sendMsg(answer);
    }
}

shared static this () {
    Router.instance().registerProcessHandler!SayHelloCommand(Commands.SayHelloReq);
}