module msgtrans.MessageTransport;

import msgtrans.MessageTransport;
import msgtrans.SessionManager;
import msgtrans.executor.Executor;
import msgtrans.executor.ExecutorInfo;

import hunt.Exceptions;
import hunt.logging.ConsoleLogger;

import std.format;


enum SERVER_NAME_PREFIX = "SERVER-";
enum CLIENT_NAME_PREFIX = "CLIENT-";

/** 
 * 
 */
abstract class MessageTransport {
    private string _name;
    private ExecutorInfo[uint] _executors;

    this(string name) {
        _name = name;
        
        ExecutorInfo[] executors = Executor.getExecutors(_name);
        foreach(ExecutorInfo e; executors) {
            _executors[e.messageId()] = e;
        }
    }

    string name() {
        return _name;
    }

    ExecutorInfo getExecutor(uint id) {
        auto itemPtr = id in _executors;
        if(itemPtr is null) {
            string msg = format("Can't find executor %d in server %s", id, _name);
            version(HUNT_DEBUG) warning(msg);
            // throw new NoSuchElementException(msg);
            return ExecutorInfo.init;
        }
        return *itemPtr;
    }

    SessionManager sessionManager() { return null; }
}

/** 
 * 
 */
struct MessageServer {
    enum NAME_PREFIX = "SERVER-";
    string name;
}

/** 
 * 
 */
struct MessageClient {
    enum NAME_PREFIX = "CLIENT-";
    string name;
}