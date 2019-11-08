module msgtrans.protocol.protobuf.TcpTransportSession;

import hunt.net;
import hunt.String;

import msgtrans.MessageBuffer;

import msgtrans.transport.TransportSession;
import msgtrans.EvBuffer;

import std.stdio;
import std.array;

import google.protobuf;

class TcpTransportSession : TransportSession
{
    private
    {
        Connection _conn = null;
    }

    this(Connection connection)
    {
        _conn = connection;
    }

    void onConnectionClosed()
    {
        _conn = null;
    }

    override void sendMsg(MessageBuffer message)
    {
        if (_conn.isConnected())
        {
            _conn.write(message);
        }
    }

    override Connection getConnection()
    {
        return _conn;
    }

    override string getProtocol()
    {
        return (cast(String)_conn.getAttribute(SESSION.PROTOCOL)).value;
    }

    override void close()
    {
        if (_conn !is null && _conn.getState() !is ConnectionState.Closed)
        {
            _conn.close();
        }
    }

    override bool isConnected()
    {
         return _conn.isConnected();
    }
}
