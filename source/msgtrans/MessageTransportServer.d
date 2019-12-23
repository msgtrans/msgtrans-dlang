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

module msgtrans.MessageTransportServer;

import msgtrans.channel.ServerChannel;
import msgtrans.MessageTransport;
import msgtrans.SessionManager;
import msgtrans.DefaultSessionManager;
import msgtrans.TransportContext;
import msgtrans.executor;

import hunt.logging.ConsoleLogger;

__gshared MessageTransportServer[string] messageTransportServers;

/**
 *
 */
class MessageTransportServer : MessageTransport {
    private string _name;
    private AcceptHandler _acceptHandler;
    private CloseHandler  _closeHandler;
    private ExecutorInfo[uint] _executors;

    private ServerChannel[string] _transportChannel;
    private SessionManager _sessionManager;

    this(string name) {
        super(SERVER_NAME_PREFIX ~ name);
    }

    MessageTransportServer addChannel(ServerChannel channel) {
        string name = channel.name();
        if (name in _transportChannel) {
            string msg = "Server exists already: " ~ name;
            warning(msg);
            throw new Exception(msg);
        }

        version (HUNT_DEBUG) {
            tracef("Registing channel: %s, type: %s", name, typeid(cast(Object) channel));
        }

        _transportChannel[name] = channel;
        return this;
    }

    void acceptor(AcceptHandler handler) {
        _acceptHandler = handler;
    }

    void closer(CloseHandler handler) {
        _closeHandler = handler;
    }

    MessageTransportServer sessionManager(SessionManager manager) {
        _sessionManager = manager;

        return this;
    }

    override SessionManager sessionManager() {
        if (_sessionManager is null) {
            _sessionManager = new DefaultSessionManager();
        }

        return _sessionManager;
    }


    void start() {
        foreach (ServerChannel t; _transportChannel) {
            t.set(this);
            t.onAccept(_acceptHandler);
            t.onClose(_closeHandler);
            t.start();
        }
    }
}
