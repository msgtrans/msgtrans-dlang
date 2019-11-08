module msgtrans.transport.tcp.TcpCodec;

import hunt.net.codec.Codec;
import hunt.net.codec.Encoder;
import hunt.net.codec.Decoder;

import msgtrans.transport.tcp.TcpDecoder;
import msgtrans.transport.tcp.TcpEncoder;

class ProtobufCodec : Codec
{
    private ProtobufEncoder _encoder = null;
    private ProtobufDecoder _decoder = null;

    this() {
        _encoder = new ProtobufEncoder();
        _decoder = new ProtobufDecoder();
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
