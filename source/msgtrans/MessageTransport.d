module msgtrans.MessageTransport;


enum SERVER_NAME_PREFIX = "SERVER-";
enum CLIENT_NAME_PREFIX = "CLIENT-";

/** 
 * 
 */
interface MessageTransport {
    string name();
}

/** 
 * 
 */
struct MessageServer {
    string name;
}

/** 
 * 
 */
struct MessageClient {
    string name;
}