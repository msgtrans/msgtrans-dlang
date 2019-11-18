module msgtrans.channel.ServerChannel;

import msgtrans.SessionManager;

/** 
 * 
 */
interface ServerChannel
{
    string name();

    void start();

    void stop();

    void setSessionManager(SessionManager manager);
}
