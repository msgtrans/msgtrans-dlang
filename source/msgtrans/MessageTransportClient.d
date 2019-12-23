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

/**
 *
 */
class MessageTransportClient : MessageTransport {
    private bool _isConnected = false;
    private ClientChannel _channel;

    this(string name) {
        super(CLIENT_NAME_PREFIX ~ name);
    }

    void transport(ClientChannel channel) {
        assert(channel !is null);
        try{
          _channel = channel;
          _channel.set(this);
          _channel.connect();
          _isConnected = true;
        }catch(Exception e){

        }
    }

    void send(MessageBuffer buffer)
    {
        _channel.send(buffer);
    }

    void send(uint id, ubyte[] msg ) {
        // if(_channel.isConnected()) {

        // } else {
        //     warning("Connection broken!");
        // }
        _channel.send(new MessageBuffer(id, msg));
    }

    bool isConnected()
    {
      return _isConnected;
    }
    void send(uint id, string msg ) {
        this.send(id, cast(ubyte[]) msg);
    }

    void close() {
        _channel.close();
    }
}
