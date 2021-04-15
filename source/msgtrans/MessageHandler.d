module msgtrans.MessageHandler;

import msgtrans.MessageBuffer;
import msgtrans.TransportContext;

alias MessageHandler = void delegate(TransportContext ctx, MessageBuffer buffer);