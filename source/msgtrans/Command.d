module msgtrans.Command;

import hunt.net;

import msgtrans.transport.TransportSession;

import msgtrans.MessageBuffer;
import msgtrans.Router;

interface Command
{
     void execute(Session connection, MessageBuffer message);
}
