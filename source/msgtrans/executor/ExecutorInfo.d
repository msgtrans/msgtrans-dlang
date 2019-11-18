module msgtrans.executor.ExecutorInfo;

import msgtrans.MessageBuffer;
import msgtrans.channel.SessionManager;
import msgtrans.channel.TransportContext;
import msgtrans.channel.TransportSession;
import witchcraft;

import hunt.logging;

import std.conv;
import std.range;

/** 
 * 
 */
struct ExecutorInfo
{
    private string _id = "";
    private int _messageId;
    private Class _classMeta;
    private Method _method;

    this(int messageId, Class classMeta, Method method) {
        this._messageId = messageId;
        this._classMeta = classMeta;
        this._method = method;
    }

    string id() {
        if(_id.empty())
            _id = _messageId.to!string();
        return _id;
    }

    /** 
     * 
     * Params:
     *   session = 
     *   buffer = 
     *   args = 
     */
    void execute(Args...)(ref TransportContext context,  
            MessageBuffer buffer, Args args) nothrow {
        try {
            string objectKey = id();
            TransportSession session = context.currentSession();
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
            _method.invoke(obj, context, buffer);
        } catch(Throwable ex) {
            warning(ex.msg);
            version(HUNT_DEBUG) warning(ex);
        }
    }
}
