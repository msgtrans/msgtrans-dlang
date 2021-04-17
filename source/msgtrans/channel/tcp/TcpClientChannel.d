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

module msgtrans.channel.tcp.TcpClientChannel;

import msgtrans.DefaultSessionManager;
import msgtrans.executor;
import msgtrans.channel.ClientChannel;
import msgtrans.channel.TransportSession;
import msgtrans.channel.tcp.TcpCodec;
import msgtrans.channel.tcp.TcpTransportSession;
import msgtrans.MessageBuffer;
import msgtrans.MessageHandler;
import msgtrans.MessageTransport;
import msgtrans.Packet;
import msgtrans.TransportContext;
import msgtrans.ee2e.message.MsgDefine;
import msgtrans.ee2e.crypto;
import msgtrans.ee2e.common;
import msgtrans.MessageTransportClient;
import hunt.Exceptions;
import hunt.io.channel.Common;
// import hunt.concurrency.FuturePromise;
import hunt.logging.ConsoleLogger;
import hunt.net;

import google.protobuf;

import std.array;
import std.base64;
import std.format;

import core.sync.condition;
import core.sync.mutex;


/**
 *
 */
class TcpClientChannel : ClientChannel {
    private string _host;
    private ushort _port;

    private MessageTransport _messageTransport;
    private NetClient _client;
    private NetClientOptions _options;
    private Connection _connection;
    private CloseHandler _closeHandler;
    private Mutex _connectLocker;
    private Condition _connectCondition;

    this(string host, ushort port) {
        _host = host;
        _port = port;

        _options = new NetClientOptions();
        _options.setIdleTimeout(15.seconds);
        _options.setConnectTimeout(5.seconds);

        _connectLocker = new Mutex();
        _connectCondition = new Condition(_connectLocker);
    }

    void set(MessageTransport transport) {
        _messageTransport = transport;
    }

    void onClose(CloseHandler handler)
    {
      _closeHandler = handler;
    }

    void keyExchangeInitiate()
    {
        KeyExchangeRequest keyExchangeRes = new KeyExchangeRequest;
        KeyInfo keyInfo = new KeyInfo;

        keyInfo.salt_32bytes = Base64.encode(MessageTransportClient.client_key.salt);
        keyInfo.ec_public_key_65bytes = Base64.encode(MessageTransportClient.client_key.ec_pub_key); //Base64.encode(MessageTransportClient.client_key.ec_pub_key);
        //logInfo("%s",MessageTransportClient.client_key.ec_pub_key);

        keyExchangeRes.key_info = keyInfo;
        keyExchangeRes.key_exchange_type = KeyExchangeType.KEY_EXCHANGE_INITIATE;

        logInfo("salt :%s",keyInfo.salt_32bytes);

        logInfo("%s",keyInfo.ec_public_key_65bytes);
        send(new MessageBuffer(MESSAGE.INITIATE,keyExchangeRes.toProtobuf.array));
    }

    private void initialize() {

        _client = NetUtil.createNetClient(_options);

        _client.setCodec(new TcpCodec());

        _client.setHandler(new class NetConnectionHandler {

            override void connectionOpened(Connection connection) {
                version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());
                _connection = connection;

                _connectLocker.lock();
                scope(exit) {
                    _connectLocker.unlock();
                }

                _connectCondition.notifyAll();
                if (MessageTransportClient.isEE2E)
                {
                  keyExchangeInitiate();
                }

            }

            override void connectionClosed(Connection connection) {
                version(HUNT_DEBUG) infof("Connection closed: %s", connection.getRemoteAddress());
                _connection = null;
                if(_closeHandler !is null)
                {
                  TransportContext t;
                  _closeHandler(t);
                }
                // client.close();
            }

            override DataHandleStatus messageReceived(Connection connection, Object message) {
                MessageBuffer buffer = cast(MessageBuffer)message;
                if(buffer is null) {
                    warningf("expected type: MessageBuffer, message type: %s", typeid(message).name);
                } else {
                    dispatchMessage(connection, buffer);
                }

                return DataHandleStatus.Done;
            }

            override void exceptionCaught(Connection connection, Throwable t) {
                debug warning(t.msg);
            }

            override void failedOpeningConnection(int connectionId, Throwable t) {
                debug warning(t.msg);
                // _client.close();
                _connectLocker.lock();
                scope(exit) {
                    _connectLocker.unlock();
                }                
                _connectCondition.notifyAll();
            }

            override void failedAcceptingConnection(int connectionId, Throwable t) {
                debug warning(t.msg);
            }
        });
    }


    private void dispatchMessage(Connection connection, MessageBuffer message ) {
        version(HUNT_DEBUG) {
            string str = format("data received: %s", message.toString());
            tracef(str);
        }

        // tx: 00 00 27 11 00 00 00 05 00 00 00 00 00 00 00 00 57 6F 72 6C 64
        // rx: 00 00 4E 21 00 00 00 0B 00 00 00 00 00 00 00 00 48 65 6C 6C 6F 20 57 6F 72 6C 64

        uint messageId = message.id;
        if (messageId == MESSAGE.INITIATE || messageId == MESSAGE.FINALIZE)
        {
            keyExchangeRequest(message,connection);
            return;
        }

        MessageHandler handler = _messageTransport.getMessageHandler(messageId);
        if(handler is null) {
            dispatchForExecutor(connection, messageId, message);
        } else {
            TransportContext context = getContext(connection);

            if (MessageTransportClient.isEE2E)
            {
                version(HUNT_DEBUG) logInfo("......................");
                message = common.encrypted_decode(message,MessageTransportClient.server_key, true);
            }            
            handler(context, message);
        }

    }

    private void dispatchForExecutor(Connection connection, uint messageId, MessageBuffer message) {

        ExecutorInfo executorInfo = _messageTransport.getExecutor(messageId);
        if(executorInfo == ExecutorInfo.init) {
            warning("No Executor found for id: ", messageId);
        } else {
            TransportContext context = getContext(connection);

            if (MessageTransportClient.isEE2E)
            {
                logInfo("......................");
                message = common.encrypted_decode(message,MessageTransportClient.server_key, true);
            }            
            executorInfo.execute(context, message);
        }
    }

    private TransportContext getContext(Connection connection) {

        enum string ChannelSession = "ChannelSession";
        TcpTransportSession session = cast(TcpTransportSession)connection.getAttribute(ChannelSession);
        if(session is null ){
            session = new TcpTransportSession(nextClientSessionId(), connection);
            connection.setAttribute(ChannelSession, session);
        }

        TransportContext context = TransportContext(null, session);


        return context;
    }

    private void keyExchangeRequest(MessageBuffer message, Connection connection)
    {
        switch(message.id)
        {
            case MESSAGE.INITIATE :
            {
                KeyExchangeRequest keyExchangeRes = new KeyExchangeRequest;
                message.data.fromProtobuf!KeyExchangeRequest(keyExchangeRes);

                MessageTransportClient.server_key.ec_pub_key = Base64.decode(keyExchangeRes.key_info.ec_public_key_65bytes);
                MessageTransportClient.server_key.salt = Base64.decode(keyExchangeRes.key_info.salt_32bytes);

                //logInfo("server pub : %s" , MessageTransportClient.server_key.ec_pub_key);
                //logInfo("service salt : %s", MessageTransportClient.server_key.salt);

                if (common.keyCalculate(MessageTransportClient.client_key,MessageTransportClient.server_key))
                {
                    send(new MessageBuffer(cast(uint)MESSAGE.FINALIZE, cast(ubyte[])[]));
                }else
                {
                    logError("keyCalculate error");
                }
                break;
            }
            case MESSAGE.FINALIZE :
            {
                 logInfo("======================Key exchange completed======================");
                 break;
            }
            default : break;
        }

    }

    void connect() {

        //if(_client !is null) {
        //    return;
        //}

        initialize();

        _client.connect(_host, _port);

        if(_client.isConnected())
            return;

        _connectLocker.lock();
        scope(exit) {
            _connectLocker.unlock();
        }

        Duration connectTimeout = _options.getConnectTimeout();
        if(connectTimeout.isNegative()) {
            version (HUNT_DEBUG) infof("connecting...");
            _connectCondition.wait();
        } else {
            version (HUNT_DEBUG) infof("waiting for the connection in %s ...", connectTimeout);
            bool r = _connectCondition.wait(connectTimeout);
            if(r) {
                if(!_client.isConnected()) {
                    string msg = format("Failed to connect to %s:%d", _host, _port);
                    warning(msg);
                    _client.close();
                    throw new IOException(msg);
                }

            } else {
                warningf("connect timeout in %s", connectTimeout);
                _client.close();
                throw new TimeoutException();
            }
        }
    }

    bool isConnected() {
        return _client !is null && _client.isConnected();
    }

    void send(MessageBuffer message) {
        if(!isConnected()) {
            throw new IOException("Connection broken!");
        }

        if (MessageTransportClient.isEE2E && (message.id != MESSAGE.INITIATE  && message.id != MESSAGE.FINALIZE))
        {
            message = common.encrypted_encode(message,MessageTransportClient.client_key,MessageTransportClient.server_key);
        }
        ubyte[][] buffers = Packet.encode(message);
        foreach(ubyte[] data; buffers) {
            _connection.write(data);
        }
    }

    void close() {
        if(_client !is null) {
            _client.close();
        }
    }
}

