module msgtrans.executor.Executor;

import msgtrans.executor.ExecutorInfo;

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
