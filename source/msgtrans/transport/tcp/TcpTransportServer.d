module msgtrans.protocol.protobuf.TcpTransportServer;

import msgtrans.transport.TransportServer;

import hunt.net.codec.Codec;

import msgtrans.ConnectionEventBaseHandler;
import msgtrans.protocol.protobuf.TcpConnectionEventHandler;
import msgtrans.transport.tcp.TcpCodec;
import msgtrans.GatewayApplication;
import msgtrans.ConnectionManager;
import msgtrans.Session;

import hunt.net.NetServerOptions;
import hunt.net;

class TcpTransportServer : TransportServer
{
    alias CloseCallBack = void delegate(Session connection);

    private
    {
        string _host;
        ushort _port;
        enum string _name = typeof(this).stringof;

        ConnectionEventBaseHandler _handler;
        NetServerOptions _options = null;
        Codec _codec;
    }

    this(string host , ushort port)
    {
        _host = host;
        _port = port;
        _handler = new TcpConnectionEventHandler(_name);
        _codec = new ProtobufCodec();
    }

    override void registerHandler()
    {
        GatewayApplication.instance().registerConnectionManager(_name);
        ConnectionManager!int manager = GatewayApplication.instance().getConnectionManager(_name);
        _handler.setOnConnection(&manager.onConnection);
        _handler.setOnClosed(&manager.onClosed);
    }

    void setDisConnectHandler (CloseCallBack handler)
    {
        GatewayApplication.instance().registerConnectionManager(_name);
        ConnectionManager!int manager = GatewayApplication.instance().getConnectionManager(_name);
        if (manager !is null )
        {
            manager.setCloseHandler(handler);
        }
    }

    void setCodec(Codec codec)
    {
        _codec = codec;
    }

    void setConnectionEventHandler(ConnectionEventBaseHandler handler)
    {
        _handler = handler;
    }

    override NetServerOptions getOptions()
    {
        return _options;
    }

    override string getName() {return _name;}

    override ushort getPort() {return _port;}

    override ConnectionEventHandler getHandler() {return _handler;}

    override Codec getCodec() {return _codec;}

    override string getHost() {return _host;}
}
