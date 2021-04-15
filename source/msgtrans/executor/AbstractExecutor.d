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

module msgtrans.executor.AbstractExecutor;

import msgtrans.MessageBuffer;
import msgtrans.MessageTransport;
import msgtrans.channel.TransportSession;
import msgtrans.executor.ExecutorInfo;

public import msgtrans.executor.Executor;
public import msgtrans.executor.MessageId;

import hunt.logging.ConsoleLogger;
import witchcraft;

import std.algorithm;
import std.conv;
import std.range;
import std.variant;


/** 
 * 
 */
class AbstractExecutor(T) : Executor if (is(T == class)) { 

    this() {
    }

    shared static this() {

        version(HUNT_DEBUG) tracef("Registering %s", T.stringof);
        Class c = T.metaof;
        const(Method)[] methods =  c.getMethods();
        ExecutorInfo[] executors;

        foreach (const Method method; methods ) {
            // trace(method.toString());
            const(Attribute)[] attrs = method.getAttributes!(MessageId)();
            // tracef("name: %s, MessageId: %s", method.getName(), method.hasAttribute!(MessageId)());
            foreach(const(Attribute) attr; attrs) {
                // trace(attr.toString());
                if(!attr.isExpression()) 
                    continue;

                Variant value = attr.get();
                // trace(value.type.toString());
                MessageId messageId = value.get!(MessageId)();
                // trace(messageId.value);

                int messageCode = messageId.value;
                bool isFound = executors.canFind!((ExecutorInfo a, uint b) => a.messageId() == b)(messageCode);
                if(isFound) {
                    warningf("message code collision: %d in %s", messageCode, c.getFullName());
                } else {
                    // Annoying const
                    executors ~= cast(ExecutorInfo)ExecutorInfo(messageCode, cast(Class)c, cast(Method)method);

                }
            }
        }

        // Register executor for Server
        const(Attribute)[] attrs = c.getAttributes!(TransportServer)();
        foreach(const(Attribute) attr; attrs) {
            // trace(attr.toString());
            if(!attr.isExpression()) 
                continue;

            Variant value = attr.get();
            // trace(value.type.toString());
            TransportServer messageServer = value.get!(TransportServer)();
            // trace(messageServer.name);
            Executor.registerExecutors(TransportServer.NAME_PREFIX ~ messageServer.name, executors);
        }


        // Register executor for Client
        attrs = c.getAttributes!(TransportClient)();
        foreach(const(Attribute) attr; attrs) {
            // trace(attr.toString());
            if(!attr.isExpression()) 
                continue;

            Variant value = attr.get();
            // trace(value.type.toString());
            TransportClient messageclient = value.get!(TransportClient)();
            // trace(messageclient.name);
            Executor.registerExecutors(TransportClient.NAME_PREFIX ~ messageclient.name, executors);
        }

    }

    mixin Witchcraft!T;
}
