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
import msgtrans.ee2e.crypto;
import hunt.logging.ConsoleLogger;

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

    MessageTransportClient channel(ClientChannel channel)
    {
        assert(channel !is null);
        _channel = channel;
        return this;
    }

    bool connect()
    {
        assert(_channel !is null);

        try {
          _channel.set(this);
          _channel.connect();
          _isConnected = true;
        } catch(Exception e) {
            return false;
        }

        return true;
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
