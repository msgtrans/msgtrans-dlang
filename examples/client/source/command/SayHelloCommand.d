module command.SayHelloCommand;

import common.helloworld;
import msgtrans.Command;
import hunt.net;
import msgtrans.Session;
import msgtrans.MessageBuffer;
import google.protobuf;
import msgtrans.Router;
import common.Commands;
import std.array;
import std.stdio;

class SayHelloCommand : Command
{
    void execute (Session connection,MessageBuffer msg)
    {
        auto resp = new HelloReply();
        msg.message.fromProtobuf!HelloReply(resp);
        writefln("%s",resp.message);
    }
}

shared static this () {
    Router.instance().registerProcessHandler!SayHelloCommand(Commands.SayHelloResp);
}