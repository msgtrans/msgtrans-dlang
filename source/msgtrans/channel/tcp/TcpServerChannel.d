/*
 * MsgTrans - Message Transport Framework for DLang. Based on TCP, WebSocket, UDP transmission protocol.
 *
 * Copyright (C) 2019 HuntLabs
 *
 * Website: https://www.msgtrans.org
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module msgtrans.channel.tcp.TcpServerChannel;

import msgtrans.MessageTransport;
import msgtrans.SessionManager;
import msgtrans.TransportContext;
import msgtrans.channel.ServerChannel;
import msgtrans.channel.TransportSession;
import msgtrans.channel.tcp.TcpCodec;
import msgtrans.channel.tcp.TcpTransportSession;

import msgtrans.MessageBuffer;
import msgtrans.executor;

import hunt.logging.ConsoleLogger;
import hunt.net;
import hunt.net.codec.Codec;

import std.format;
import std.uuid;

/**
 *
 */
class TcpServerChannel : ServerChannel {
    private NetServer _server;
    private MessageTransport _messageTransport;
    private SessionManager _sessionManager;
    private AcceptHandler _acceptHandler;
    private CloseHandler _closeHandler;
    private string _name = typeof(this).stringof;

    enum string ChannelSession = "ChannelSession";

    private {
        string _host;
        ushort _port;

        NetServerOptions _options = null;
    }

    this(ushort port) {
        this("0.0.0.0", port);
    }

    this(string host, ushort port) {
        this(host, port, new NetServerOptions());
    }

    this(string host, ushort port, NetServerOptions options) {
        _host = host;
        _port = port;
        _options = options;
        // _name = randomUUID().toString();
    }

    string name() {
        return _name;
    }

    ushort port() {
        return _port;
    }

    string host() {
        return _host;
    }

    void set(MessageTransport transport) {
        _messageTransport = transport;
        _sessionManager = transport.sessionManager();
    }

    void start() {
        initialize();
        _server.listen(host, port);
    }

    void stop() {
        if (_server !is null)
            _server.close();
    }

    void onAccept(AcceptHandler handler) {
        _acceptHandler = handler;
    }

    void onClose(CloseHandler handler)
    {
        _closeHandler = handler;
    }

    private void initialize() {
        // dfmt off
        _server = NetUtil.createNetServer!(ThreadMode.Single)(_options);

        _server.setCodec(new TcpCodec());

        _server.setHandler(new class NetConnectionHandler {

            override void connectionOpened(Connection connection) {
                version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());
                TcpTransportSession session = new TcpTransportSession(_sessionManager.generateId(), connection);
                connection.setAttribute(ChannelSession, session);
                _sessionManager.add(session);
                TransportContext context = TransportContext(_sessionManager, session);
                if(_acceptHandler !is null) {
                    _acceptHandler(context);
                }
            }

            override void connectionClosed(Connection connection) {
                version(HUNT_DEBUG) infof("Connection closed: %s", connection.getRemoteAddress());
                TransportSession session = cast(TransportSession)connection.getAttribute(ChannelSession);
                if(session !is null ) {
                    _sessionManager.remove(session);
                }
                if (_closeHandler !is null)
                {
                  TransportContext context = TransportContext(_sessionManager, session);
                  _closeHandler(context);
                }
            }

            override void messageReceived(Connection connection, Object message) {
                MessageBuffer buffer = cast(MessageBuffer) message;
                if(buffer is null) {
                    warningf("expected type: MessageBuffer, message type: %s", typeid(message).name);
                } else {
                    dispatchMessage(connection, buffer);
                }
            }

            override void exceptionCaught(Connection connection, Throwable t) {
                debug warning(t.msg);
            }

            override void failedOpeningConnection(int connectionId, Throwable t) {
                debug warning(t.msg);
            }

            override void failedAcceptingConnection(int connectionId, Throwable t) {
                debug warning(t.msg);
            }
        });

        // dfmt on
    }

    private void dispatchMessage(Connection connection, MessageBuffer message) {
        version (HUNT_DEBUG) {
            string str = format("data received: %s", message.toString());
            tracef(str);
        }

        // rx: 00 00 27 11 00 00 00 05 00 00 00 00 00 00 00 00 57 6F 72 6C 64
        // tx: 00 00 4E 21 00 00 00 0B 00 00 00 00 00 00 00 00 48 65 6C 6C 6F 20 57 6F 72 6C 64

        uint messageId = message.id;
        ExecutorInfo executorInfo = _messageTransport.getExecutor(messageId);
        if (executorInfo == ExecutorInfo.init) {
            warning("No Executor found for id: ", messageId);
        } else {
            TcpTransportSession session = cast(TcpTransportSession) connection.getAttribute(
                    ChannelSession);
            if (session is null) {
                session = new TcpTransportSession(_sessionManager.generateId(), connection);
                connection.setAttribute(ChannelSession, session);
                _sessionManager.add(session);
            }

            TransportContext context = TransportContext(_sessionManager, session);
            executorInfo.execute(context, message);
        }
    }
}
