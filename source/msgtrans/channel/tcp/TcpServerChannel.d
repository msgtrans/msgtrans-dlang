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
import msgtrans.MessageTransportServer;
import msgtrans.MessageBuffer;
import msgtrans.executor;
import msgtrans.ee2e.message.MsgDefine;
import msgtrans.ee2e.crypto;
import hunt.logging.ConsoleLogger;
import hunt.net;
import hunt.net.codec.Codec;
import google.protobuf;
import std.array;
import msgtrans.ee2e.common;
import std.format;
import std.uuid;
import std.base64;
import core.time;

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
        auto option = new NetServerOptions();
        option.setTcpKeepAlive(true);
        option.setKeepaliveWaitTime(60.seconds);
        this(host, port, option);
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
        if (messageId == MESSAGE.INITIATE || messageId == MESSAGE.FINALIZE)
        {
            keyExchangeRequest(message,connection);
            return;
        }

       // string str = format("data received: %s", message.toString());
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
            if (MessageTransportServer.isEE2E)
            {
                peerkey_s peerkeys = cast(peerkey_s)(context.session().getAttribute("EE2E"));
                if(peerkeys !is null)
                {
                    message = common.encrypted_decode(message,peerkeys);
                    if(message is null)
                    {
                        connection.close();
                        return;
                    }
                }else
                {
                    logError("peerkeys is null");
                }
            }
            executorInfo.execute(context, message);
        }
    }

    private void keyExchangeRequest(MessageBuffer message, Connection connection)
    {
        TcpTransportSession session = cast(TcpTransportSession) connection.getAttribute(
        ChannelSession);
        if (session is null) {
          session = new TcpTransportSession(_sessionManager.generateId(), connection);
          connection.setAttribute(ChannelSession, session);
          _sessionManager.add(session);
        }
        TransportContext context = TransportContext(_sessionManager, session);

        switch(message.id)
        {
            case MESSAGE.INITIATE :
            {
                KeyExchangeRequest keyExchangeRes = new KeyExchangeRequest;
                message.data.fromProtobuf!KeyExchangeRequest(keyExchangeRes);

                //logInfo("%s",keyExchangeRes.key_info.ec_public_key_65bytes);

                peerkey_s peerkeys = new peerkey_s;
                peerkeys.ec_pub_key = Base64.decode(keyExchangeRes.key_info.ec_public_key_65bytes);
                peerkeys.salt = Base64.decode(keyExchangeRes.key_info.salt_32bytes);
                context.session().setAttribute("EE2E",peerkeys);
                logInfo("client pub : %s" ,peerkeys.ec_pub_key );
                logInfo("client salt : %s" , peerkeys.salt);


                KeyExchangeRequest res = new KeyExchangeRequest;
                KeyInfo info = new KeyInfo;
                info.ec_public_key_65bytes = Base64.encode(MessageTransportServer.s_server_key.ec_pub_key);
                info.salt_32bytes = Base64.encode(MessageTransportServer.s_server_key.salt);
                res.key_info = info;
                logInfo("server pub : %s" ,res.key_info.ec_public_key_65bytes );
                logInfo("server salt : %s" , res.key_info.salt_32bytes);

                context.session().send(new MessageBuffer(MESSAGE.INITIATE, res.toProtobuf.array));
                break;
            }
            case MESSAGE.FINALIZE :
            {
                peerkey_s peerkeys  =  cast(peerkey_s)(context.session().getAttribute("EE2E"));
                if (peerkeys !is null && common.keyCalculate(MessageTransportServer.s_server_key, peerkeys))
                {
                    context.session().send(new MessageBuffer(MESSAGE.FINALIZE, []));
                }else
                {
                    logError("peerkeys is null");
                }
                break;
            }
            default: break;
        }


    }
}
