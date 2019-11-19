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
import msgtrans.MessageTransport;
import msgtrans.Packet;
import msgtrans.TransportContext;

import hunt.Exceptions;
// import hunt.concurrency.FuturePromise;
import hunt.logging.ConsoleLogger;
import hunt.net;


import core.sync.condition;
import core.sync.mutex;

import std.format;

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

    private void initialize() {

        _client = NetUtil.createNetClient(_options);

        _client.setCodec(new TcpCodec());

        _client.setHandler(new class NetConnectionHandler {

            override void connectionOpened(Connection connection) {
                version(HUNT_DEBUG) infof("Connection created: %s", connection.getRemoteAddress());
                _connection = connection;
                _connectCondition.notifyAll();
            }

            override void connectionClosed(Connection connection) {
                version(HUNT_DEBUG) infof("Connection closed: %s", connection.getRemoteAddress());
                _connection = null;

                // client.close();
            }

            override void messageReceived(Connection connection, Object message) {
                MessageBuffer buffer = cast(MessageBuffer)message;
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
                // _client.close(); 
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
        ExecutorInfo executorInfo = _messageTransport.getExecutor(messageId);
        if(executorInfo == ExecutorInfo.init) {
            warning("No Executor found for id: ", messageId);
        } else {
            enum string ChannelSession = "ChannelSession";
            TcpTransportSession session = cast(TcpTransportSession)connection.getAttribute(ChannelSession);
            if(session is null ){
                session = new TcpTransportSession(nextClientSessionId(), connection);
                connection.setAttribute(ChannelSession, session);
            }
            
            TransportContext context = TransportContext(null, session);
            executorInfo.execute(context, message);
        }
    }

    void connect() {
        _connectLocker.lock();
        scope(exit) {
            _connectLocker.unlock();
        }

        if(_client !is null) {
            return;
        }

        initialize();
        
        _client.connect(_host, _port);

        if(_client.isConnected())
            return;

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

