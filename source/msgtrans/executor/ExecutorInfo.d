module msgtrans.executor.ExecutorInfo;

/** 
 * 
 */
struct ExecutorInfo
{
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
