/*
 * MsgTrans - Message Transport Framework for DLang. Based on TCP, WebSocket, UDP transmission protocol.
 *
 * Copyright (C) 2019 HuntLabs
 *
 * Website: https://www.msgtrans.org
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module msgtrans.executor.Executor;

import msgtrans.executor.ExecutorInfo;

import hunt.logging.ConsoleLogger;

import std.algorithm;
import std.format;
import std.range;

/** 
 * 
 */
interface Executor {
    // Grouped by the name
    private __gshared ExecutorInfo[][string] _executors;

    static void registerExecutors(string name, ExecutorInfo[] executors...) {
        
        version(HUNT_DEBUG) {
            foreach(ExecutorInfo e; executors) {
                  tracef("Registing executor to %s, id: %d, method: %s in %s", name, e.messageId(), 
                    e.methodInfo().getName(), e.classInfo().getFullName());  
            }
        }     

        auto itemPtr = name in _executors;
        if(itemPtr is null) {
            _executors[name] = executors.dup;
        } else {
            // collision check
            ExecutorInfo[] existedexecutors = _executors[name];

            foreach(ExecutorInfo e; executors) {
                ExecutorInfo[] executorInfoes = existedexecutors.find!((ExecutorInfo a, uint b) 
                    => a.messageId() == b)(e.messageId);

                if(executorInfoes.length > 0) {
                    ExecutorInfo executorInfo = executorInfoes[0];
                    string msg = format("MessageId collision: id=%d in %s, between %s and %s",
                        e.messageId, name, e.classInfo().getFullName(), executorInfo.classInfo().getFullName());
                    warningf(msg);
                    throw new Exception(msg);
                }    
            }

            _executors[name] ~= executors.dup;
        }
    }

    static ExecutorInfo[] getExecutors(string name) {
        auto itemPtr = name in _executors;
        if(itemPtr is null)
            return null;
        return *itemPtr;
    }
}
