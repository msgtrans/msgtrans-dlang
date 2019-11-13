module msgtrans.transport.tcp.TcpDecoder;

import msgtrans.PacketParser;
import msgtrans.MessageBuffer;

// import msgtrans.ParserBase;
// import hunt.net.codec.Decoder;
// import hunt.net.Connection;
// import hunt.net.Exceptions;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.Exceptions;
import hunt.logging.ConsoleLogger;
import hunt.net;

// import hunt.String;
// import msgtrans.EvBuffer;

import std.algorithm;
import std.conv;


class TcpDecoder : DecoderChain {
    private enum string PARSER = "PacketParser";

    /** The default maximum buffer length. Default to 128 chars. */
    private int bufferLength = 128;

    /** The default maximum Line length. Default to 1024. */
    private int maxLineLength = 8*1024;


    this() {
        super(null);
    }
    
    
    /**
     * @return the allowed maximum size of the line to be decoded.
     * If the size of the line to be decoded exceeds this value, the
     * decoder will throw a {@link BufferDataException}.  The default
     * value is <tt>1024</tt> (1KB).
     */
    int getMaxLineLength() {
        return maxLineLength;
    }

    /**
     * Sets the allowed maximum size of the line to be decoded.
     * If the size of the line to be decoded exceeds this value, the
     * decoder will throw a {@link BufferDataException}.  The default
     * value is <tt>1024</tt> (1KB).
     * 
     * @param maxLineLength The maximum line length
     */
    void setMaxLineLength(int maxLineLength) {
        if (maxLineLength <= 0) {
            throw new IllegalArgumentException("maxLineLength (" ~ 
                maxLineLength.to!string() ~ ") should be a positive value");
        }

        this.maxLineLength = maxLineLength;
    }

    /**
     * Sets the default buffer size. This buffer is used in the Context
     * to store the decoded line.
     *
     * @param bufferLength The default bufer size
     */
    void setBufferLength(int bufferLength) {
        if (bufferLength <= 0) {
            throw new IllegalArgumentException("bufferLength (" ~ 
                maxLineLength.to!string() ~ ") should be a positive value");

        }

        this.bufferLength = bufferLength;
    }

    /**
     * @return the allowed buffer size used to store the decoded line
     * in the Context instance.
     */
    int getBufferLength() {
        return bufferLength;
    }

    override
    void decode(ByteBuffer buf, Connection connection) { 
        tracef("connection %d: %s", connection.getId(), buf.toString());
        PacketParser parser = getParser(connection);

        MessageBuffer[] msgBuffers = parser.parse(buf);
        if(msgBuffers is null) {
            warning("no message frame parsed.");
            return;
        }

        NetConnectionHandler handler = connection.getHandler();
        if(handler is null) {
            warning("No handler found");
            return;
        }

        foreach(MessageBuffer msg; msgBuffers) {
            handler.messageReceived(connection, msg);
        }

    } 

    private PacketParser getParser(Connection connection) {
        PacketParser ctx;
        ctx = cast(PacketParser) connection.getAttribute(PARSER);

        if (ctx is null) {
            ctx = new PacketParser(bufferLength);
            connection.setAttribute(PARSER, ctx);
        }

        return ctx;
    }


    void dispose(Connection connection) {
        PacketParser ctx = cast(PacketParser) connection.getAttribute(PARSER);

        if (ctx !is null) {
            connection.removeAttribute(PARSER);
        }
    }

}

// class ProtobufDecoder : ParserBase , Decoder {

//     override void decode(ByteBuffer buf, Connection connection)
//     {
//        EvBuffer!ubyte revbuferr = getContext(connection);
//        parserTcpStream(revbuferr, cast(ubyte[])buf.getRemaining(), connection);
//     }


//     private EvBuffer!ubyte getContext(Connection connection) {
//         EvBuffer!ubyte revbuferr = null;
//         revbuferr = cast(EvBuffer!ubyte) connection.getAttribute(PARSER);

//         if (revbuferr is null) {
//             revbuferr = new EvBuffer!ubyte ;
//             connection.setAttribute(PARSER, revbuferr);
//         }
//         return revbuferr;
//     }
// }
