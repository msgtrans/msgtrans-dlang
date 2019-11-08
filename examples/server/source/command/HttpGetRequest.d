module action.HttpGetRequest;

import common.Commands;
import msgtrans.Router;
import msgtrans.Command;
import msgtrans.Session;
import msgtrans.MessageBuffer;
import msgtrans.ParserBase;
import hunt.util.Serialize;
import hunt.logging;
class HttpGetRequest : Command {
    void execute (Session connection,MessageBuffer msg)
     {
         HttpContent  content = unserialize!HttpContent(cast(byte[])msg.message);
         content.reset();
         content.status = 200;
         content.body = "hello world " ~ content.body;

         MessageBuffer anser = new MessageBuffer(-1,cast(ubyte[])serialize!HttpContent(content));
         connection.sendMsg(anser);
     }
}

shared static this () {
    Router.instance().registerProcessHandler!HttpGetRequest(cast(int)hashOf("/test"));
}
