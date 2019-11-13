module msgtrans.transport.tcp.TcpCodec;

import hunt.net.codec.Codec;
import hunt.net.codec.Encoder;
import hunt.net.codec.Decoder;

import msgtrans.transport.tcp.TcpDecoder;
import msgtrans.transport.tcp.TcpEncoder;

class TcpCodec : Codec
{
    private TcpEncoder _encoder = null;
    private TcpDecoder _decoder = null;

    this() {
        _encoder = new TcpEncoder();
        _decoder = new TcpDecoder();
    }

    Encoder getEncoder()
    {
        return _encoder;
    }

    Decoder getDecoder()
    {
        return _decoder;
    }
}
