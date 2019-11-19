module msgtrans.channel.ServerChannel;

import msgtrans.MessageTransport;
// import msgtrans.SessionManager;
import msgtrans.TransportContext;

/** 
 * 
 */
interface ServerChannel {
    string name();

    void start();

    void stop();

    // void setSessionManager(SessionManager manager);
    void set(MessageTransport transport);

    void onAccept(ContextHandler handler);

}
