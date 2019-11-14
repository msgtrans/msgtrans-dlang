module msgtrans.transport.ServerChannel;

// import hunt.net.codec.Codec;
// import hunt.imf.ConnectionEventBaseHandler;
// import hunt.net.NetServerOptions;
import hunt.net;

/** 
 * 
 */
interface ServerChannel
{
    string name();

    // ushort port();

    // string host();

    // ConnectionEventHandler getHandler();

    // Codec getCodec();

    // NetServerOptions getOptions();

    // void registerHandler();

    void start();
}
