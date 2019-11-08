module msgtrans.transport.tcp.TcpDecoder;

import msgtrans.ParserBase;
import hunt.net.codec.Decoder;
import hunt.net.Connection;
import hunt.net.Exceptions;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.String;
import msgtrans.EvBuffer;

import std.algorithm;
import std.conv;


class ProtobufDecoder : ParserBase , Decoder {

    override void decode(ByteBuffer buf, Connection connection)
    {
       EvBuffer!ubyte revbuferr = getContext(connection);
       parserTcpStream(revbuferr, cast(ubyte[])buf.getRemaining(), connection);
    }


    private EvBuffer!ubyte getContext(Connection connection) {
        EvBuffer!ubyte revbuferr = null;
        revbuferr = cast(EvBuffer!ubyte) connection.getAttribute(CONTEXT);

        if (revbuferr is null) {
            revbuferr = new EvBuffer!ubyte ;
            connection.setAttribute(CONTEXT, revbuferr);
        }
        return revbuferr;
    }
}
