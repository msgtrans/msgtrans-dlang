module msgtrans.Executor;

import msgtrans.MessageBuffer;
import msgtrans.transport.TransportSession;

import hunt.logging.ConsoleLogger;
import witchcraft;

import std.conv;
import std.range;
import std.variant;


struct MessageId {
    uint value;
}

/** 
 * 
 */
struct ExecutorInfo {
    private string _id = "";
    private int _messageCode;
    private Class _classMeta;
    private Method _method;

    this(int messageCode, Class classMeta, Method method) {
        this._messageCode = messageCode;
        this._classMeta = classMeta;
        this._method = method;
    }

    string id() {
        if(_id.empty())
            _id = _messageCode.to!string();
        return _id;
    }

    /** 
     * 
     * Params:
     *   session = 
     *   buffer = 
     *   args = 
     */
    void execute(Args...)(TransportSession session, MessageBuffer buffer, Args args) nothrow {
        try {
            string objectKey = id();
            Object obj = session.getAttribute(objectKey);
            if(obj is null) {
                obj = _classMeta.create();
                session.setAttribute(objectKey, obj);
            }
            // switch(id)
            // {
            //     case 10001:
            //         string msg = cast(string)codec.decode(ubyte[]);
            //         this.hello(ctx, msg);
            // }
            // string msg = cast(string)codec.decode(ubyte[]);
            _method.invoke(obj, session, buffer);
        } catch(Throwable ex) {
            warning(ex.msg);
            version(HUNT_DEBUG) warning(ex);
        }
    }
}

/** 
 * 
 */
interface Executor {
    // __gshared const(ExecutorInfo)[int] executors;
    __gshared ExecutorInfo[int] executors;

    static ExecutorInfo getExecutor(int code) {
        auto itemPtr = code in executors;
        if(itemPtr is null)
            return ExecutorInfo.init;
        return *itemPtr;
    }
}


/** 
 * 
 */
class AbstractExecutor(T) : Executor if (is(T == class)) { 
    // && __traits(compiles, new T())
    // && is(typeof(new T()))

    // TODO: Tasks pending completion -@zhangxueping at 2019-11-14T18:50:12+08:00
    // To check the default constructor.

    shared static this() {

        tracef("Registering %s", T.stringof);
        Class c = T.metaof;
        const(Method)[] methods =  c.getMethods();

        foreach (const Method method; methods ) {
            // trace(method.toString());
            const(Attribute)[] attrs = method.getAttributes!(MessageId)();
            // tracef("name: %s, MessageId: %s", method.getName(), method.hasAttribute!(MessageId)());

            foreach(const(Attribute) attr; attrs) {
                // trace(attr.toString());
                if(attr.isExpression()) {
                    Variant value = attr.get();
                    // trace(value.type.toString());
                    MessageId messageId = value.get!(MessageId)();
                    // trace(messageId.value);

                    int messageCode = messageId.value;
                    if(messageCode in executors) {
                        warningf("message code collision: %d in %s", messageCode, c.getFullName());
                    } else {
                        // Annoying const
                        executors[messageCode] = cast(ExecutorInfo) ExecutorInfo(messageCode, 
                            cast(Class)c, cast(Method)method);

                        infof("Executor registered, code:%d, method: %s in %s", messageCode, 
                            method.getName(), c.getFullName());
                    }
                } 
            }
        }
    }


    mixin Witchcraft!T;
}
