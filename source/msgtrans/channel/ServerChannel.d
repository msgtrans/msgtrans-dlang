module msgtrans.channel.ServerChannel;

import msgtrans.channel.SessionManager;

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
