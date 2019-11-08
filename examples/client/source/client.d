import std.stdio;

import msgtrans.protocol.Protocol;
import msgtrans.transport.tcp.TcpProtocol;
import common.Commands;
import common.helloworld;
import google.protobuf;
import std.array;
import msgtrans.clients.GatewayClient;
import msgtrans.clients.GatewayWebSocketClient;
import msgtrans.protocol.websocket.WsProtocol;
import msgtrans.clients.GatewayHttpClient;
import msgtrans.protocol.http.HttpProtocol;
import msgtrans.clients.GatewayTcpClient;
import msgtrans.ParserBase;
import core.thread;
import hunt.logging;
void main()
{
	auto req = new HelloRequest ();
	req.name = "1234567890abcdefjhijklmnopqrstuvwxyz";

    WsProtocol ws = new WsProtocol("127.0.0.1",18181);
	GatewayWebSocketClient wsclient = new GatewayWebSocketClient(ws);
	wsclient.connect();

	wsclient.sendMsg(Commands.SayHelloReq,req);

//-------------------------------------------------------------------

	ProtobufProtocol tcp = new ProtobufProtocol("127.0.0.1",12001);
	GatewayTcpClient tcpclient = new GatewayTcpClient(tcp);
	tcpclient.connect();
	tcpclient.sendMsg(Commands.SayHelloReq,req);

	getchar();
}
