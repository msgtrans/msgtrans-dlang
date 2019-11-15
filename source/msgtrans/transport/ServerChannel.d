module msgtrans.transport.ServerChannel;

/** 
 * 
 */
interface ServerChannel
{
    string name();

    void start();

    void stop();
}
