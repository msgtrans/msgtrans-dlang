module msgtrans.channel.ServerChannel;

import msgtrans.SessionManager;
import msgtrans.TransportContext;


/** 
 * 
 */
interface ServerChannel
{
    string name();

    void start();

    void stop();

    void setSessionManager(SessionManager manager);

    void setAcceptHandler(ContextHandler handler);

}
