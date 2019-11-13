module msgtrans.MessageExecutor;

import hunt.logging.ConsoleLogger;
import witchcraft;

import std.variant;

struct ExecutorInfo {
    int messageCode;
    Class classMeta;
    Method method;

    void execute(Args...)(Args args) nothrow {
        try {
            Object obj = classMeta.create();
            // switch(id)
            // {
            //     case 10001:
            //         string msg = cast(string)codec.decode(ubyte[]);
            //         this.hello(ctx, msg);
            // }
            // string msg = cast(string)codec.decode(ubyte[]);
            method.invoke(obj, args);
        } catch(Throwable ex) {
            warning(ex.msg);
        }
    }
}


interface MessageExecutor {
    // __gshared const(ExecutorInfo)[int] executors;
    __gshared ExecutorInfo[int] executors;

    static ExecutorInfo getExecutor(int code) {
        auto itemPtr = code in executors;
        if(itemPtr is null)
            return ExecutorInfo.init;
        return *itemPtr;
    }
}


class AbstractMessageExecutor(T) : MessageExecutor {

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
                    // trace(messageId.code);

                    int messageCode = messageId.code;
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

class ExecutorContext {
    
}

struct MessageId {
    int code;
}