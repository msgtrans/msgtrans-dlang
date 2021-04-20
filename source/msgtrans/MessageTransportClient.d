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
import msgtrans.MessageHandler;
import msgtrans.ee2e.crypto;
import msgtrans.TransportContext;

import hunt.logging.ConsoleLogger;
import hunt.concurrency.FuturePromise;

import core.time;

/**
 *
 */
class MessageTransportClient : MessageTransport {
    private bool _isConnected = false;
    private ClientChannel _channel;
    __gshared bool isEE2E;
    __gshared ownkey_s  client_key;
    __gshared peerkey_s server_key;
    private CloseHandler  _closeHandler;
    shared static this()
    {
        client_key = new ownkey_s;
        server_key = new peerkey_s;
        isEE2E = false;
    }

    // private Duration _tickPeriod = 10.seconds;
    // private Duration _ackTimeout = 30.seconds;
    // private uint _missedAcks = 3;

    this(string name ,bool ee2e = false)
    {
        if (!name.length)
        {
            // Exeption?
        }

        if(ee2e)
        {
            if (!generate_ecdh_keys(client_key.ec_pub_key, client_key.ec_priv_key))
            {
                logError("ECDH-KEY generation failed.");
            }
            logInfo("%s",client_key.ec_pub_key);
            /* Generate a random number that called salt */
            if (!rand_salt(client_key.salt, CRYPTO_SALT_LEN))
            {
                logError("Random salt generation failed.");
            }
            isEE2E = true;
        }

        super(CLIENT_NAME_PREFIX ~ name);
    }

    void closer(CloseHandler handler) {
      _closeHandler = handler;
    }

    MessageTransportClient channel(ClientChannel channel)
    {
        assert(channel !is null);
        _channel = channel;
        return this;
    }

    bool isConnected()
    {
      return _isConnected;
    }

    bool connect()
    {
        assert(_channel !is null);

        try {
          _channel.set(this);
          _channel.connect();
          _channel.onClose(_closeHandler);
          _isConnected = true;
        } catch(Exception e) {
            warning(e);
            return false;
        }

        return true;
    }

    void send(MessageBuffer buffer)
    {
        _channel.send(buffer);
    }

    void send(uint id, ubyte[] msg) {
        _channel.send(new MessageBuffer(id, msg));
    }

    void send(uint id, string msg) {
        this.send(id, cast(ubyte[]) msg);
    }

    
    MessageBuffer Call(MessageBuffer buffer, Duration timeout = 5.seconds) {
        FuturePromise!MessageBuffer promise = new FuturePromise!MessageBuffer();

        this.registerHandler(buffer.id, (ctx, buf) {
            promise.succeeded(buf);
        });

        scope(exit) {
            this.deregisterHandler(buffer.id);
        }

        _channel.send(buffer);

        MessageBuffer responseBuffer = promise.get(timeout);
        return responseBuffer;
    }

    void AsyncCall(MessageBuffer buffer, MessageHandler handler) {
        this.registerHandler(buffer.id, handler);
        _channel.send(buffer);
    }

    void close() {
        _channel.close();
    }

  bool isClosed()
  {
    bool c = !_channel.isConnected;
    if(c)
    {
      _isConnected = false;
    }
    return c;
  }
}
