import std.stdio;

import hunt.net;
import hunt.logging;

import msgtrans.protocol.protobuf.TcpConnectionEventHandler;
import msgtrans.protocol.Protocol;
import msgtrans.transport.tcp.TcpProtocol;
import msgtrans.protocol.http.HttpProtocol;
import msgtrans.GatewayApplication;
import msgtrans.protocol.websocket.WsProtocol;

import core.thread;

void main()
{
	GatewayApplication app = GatewayApplication.instance();

	ProtobufProtocol tcp = new ProtobufProtocol("0.0.0.0",12001);
	WsProtocol ws = new WsProtocol("0.0.0.0", 18181);

	app.addServer(tcp);
	app.addServer(ws);

	app.run();
}
