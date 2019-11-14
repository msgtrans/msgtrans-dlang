module msgtrans.transport.tcp.TcpServerChannel;

import msgtrans.transport.ServerChannel;
import msgtrans.transport.TransportSession;
import msgtrans.MessageBuffer;
import msgtrans.MessageExecutor;


// import msgtrans.ConnectionEventBaseHandler;
// import msgtrans.protocol.protobuf.TcpConnectionEventHandler;
import msgtrans.transport.tcp.TcpCodec;
import msgtrans.transport.tcp.TcpTransportSession;

import hunt.logging.ConsoleLogger;
import hunt.net;
import hunt.net.codec.Codec;

import std.format;
import std.uuid;

/**
 * 
 */
class TcpServerChannel : ServerChannel
{
    // alias CloseCallBack = void delegate(Session connection);

    private NetServer _server;
    private string _name = typeof(this).stringof;

    private
    {
        string _host;
        ushort _port;

        NetServerOptions _options = null;
    }

    this(ushort port) {
        this("0.0.0.0", port);
    }

    this(string host , ushort port)
    {
        this(host, port, new NetServerOptions());
    }

    this(string host , ushort port, NetServerOptions options)
    {
        _host = host;
        _port = port;
        // _handler = new TcpConnectionEventHandler(_name);
        // _codec = new TcpCodec();
        _options = options;
        // _name = randomUUID().toString();
    }

    string name() {
        return _name;
    }

    ushort port() {return _port;}

    string host() {return _host;}

    void start() {
        initialize();
        _server.listen(host, port);
    }

    private void initialize() {
        _server = NetUtil.createNetServer!(ThreadMode.Single)(_options);

        _server.setCodec(new TcpCodec());

        _server.setHandler(new class NetConnectionHandler {

            override void connectionOpened(Connection connection) {
                infof("Connection created: %s", connection.getRemoteAddress());
            }

            override void connectionClosed(Connection connection) {
                infof("Connection closed: %s", connection.getRemoteAddress());
            }

            override void messageReceived(Connection connection, Object message) {
                MessageBuffer buffer = cast(MessageBuffer) message;
                if(buffer is null) {
                    warningf("expected tyep: MessageBuffer, message type: %s", typeid(message).name);
                } else {
                    dispatchMessage(connection, buffer);
                }
                // connection.write(str);
            }

            override void exceptionCaught(Connection connection, Throwable t) {
                warning(t);
            }

            override void failedOpeningConnection(int connectionId, Throwable t) {
                warning(t);
            }

            override void failedAcceptingConnection(int connectionId, Throwable t) {
                warning(t);
            }
        });      
    }

    static void dispatchMessage(Connection connection , MessageBuffer message ) {
        
        string str = format("data received: %s", message.toString());
        tracef(str);
        ExecutorInfo executorInfo = MessageExecutor.getExecutor(message.id);
        if(executorInfo == ExecutorInfo.init) {
            warning("No Executor found for id: ", message.id);
        } else {
            enum string ChannelSession = "ChannelSession";
            TcpTransportSession session = cast(TcpTransportSession)connection.getAttribute(ChannelSession);
            if(session is null ){
                session = new TcpTransportSession(nextServerSessionId(), connection);
                connection.setAttribute(ChannelSession, session);
            }
            executorInfo.execute(session, message.data);
        }
        // Command handler =  Router.instance().getProcessHandler(message.messageId);
        // if (handler !is null)
        // {
        //     handler.execute(connection,message);
        // } else {
        //     logError("Unknown msgType %d",message.messageId );
        // }
    }
}
