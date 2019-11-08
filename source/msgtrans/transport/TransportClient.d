module msgtrans.transport.TransportClient;

import std.typecons;

import msgtrans.ConnectionEventBaseHandler;
import msgtrans.protocol.protobuf.TcpConnectionEventHandler;
import msgtrans.protocol.protobuf.TcpSession;
import msgtrans.protocol.Protocol;

import core.thread;
import core.sync.condition;
import core.sync.mutex;

import msgtrans.MessageBuffer;
import msgtrans.Session;

import hunt.logging;
import hunt.net;

interface TransportClient {

    void onConnection (Session session);

    //void sendMsg(int tid,ubyte[] msg) ;

    void connect() ;

    void onClosed(Session session);
}
