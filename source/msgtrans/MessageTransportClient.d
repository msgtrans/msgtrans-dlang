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

module msgtrans.MessageTransportClient;

import msgtrans.channel.ClientChannel;
import msgtrans.executor;
import msgtrans.MessageTransport;
import msgtrans.MessageBuffer;

import hunt.logging.ConsoleLogger;

import core.time;

/**
 *
 */
class MessageTransportClient : MessageTransport {
    private bool _isConnected = false;
    private ClientChannel _channel;

    // private Duration _tickPeriod = 10.seconds;
    // private Duration _ackTimeout = 30.seconds;
    // private uint _missedAcks = 3;

    this(string name) {
        if (!name.length) {
            // Exeption?
        }

        super(CLIENT_NAME_PREFIX ~ name);
    }

    MessageTransportClient channel(ClientChannel channel) {
        assert(channel !is null, "The channel can't be null.");
        _channel = channel;
        connect();
        return this;
    }

    bool connect() {
        assert(_channel !is null, "The channel is not set.");

        try {
            _channel.set(this);
            _channel.connect();
            _isConnected = true;
        } catch (Exception e) {
            return false;
        }

        return true;
    }

    void send(MessageBuffer buffer) {
        _channel.send(buffer);
    }

    void send(uint id, ubyte[] msg) {
        assert(_channel !is null, "The channel is not set.");
        // if(_channel.isConnected()) {

        // } else {
        //     warning("Connection broken!");
        // }
        _channel.send(new MessageBuffer(id, msg));
    }

    bool isConnected() {
        return _isConnected;
    }

    void send(uint id, string msg) {
        this.send(id, cast(ubyte[]) msg);
    }

    void close() {
        _channel.close();
    }
}
