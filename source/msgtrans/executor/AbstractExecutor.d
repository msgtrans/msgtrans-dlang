module msgtrans.executor.AbstractExecutor;

import msgtrans.MessageBuffer;
import msgtrans.channel.TransportSession;
import msgtrans.executor.ExecutorInfo;

public import msgtrans.executor.Executor;
public import msgtrans.executor.MessageId;

import hunt.logging.ConsoleLogger;
import witchcraft;

import std.conv;
import std.range;
import std.variant;

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
                        
                        // MessageTransportFactory.getServer("test").addExecutor(cast(ExecutorInfo) ExecutorInfo(messageCode, 
                        //     cast(Class)c, cast(Method)method));

                        infof("Executor registered, code:%d, method: %s in %s", messageCode, 
                            method.getName(), c.getFullName());
                    }
                } 
            }
        }
    }

    mixin Witchcraft!T;
}
