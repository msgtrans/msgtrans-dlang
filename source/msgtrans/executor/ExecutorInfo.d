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

module msgtrans.executor.ExecutorInfo;

import msgtrans.MessageBuffer;
import msgtrans.TransportContext;
import msgtrans.channel.TransportSession;

import hunt.logging.ConsoleLogger;
import witchcraft;

import std.conv;
import std.range;

/**
 *
 */
struct ExecutorInfo {
    private string _id = "";
    private uint _messageId;
    private Class _classInfo;
    private Method _methodInfo;

    this(uint messageId, Class classInfo, Method method) {
        this._messageId = messageId;
        this._classInfo = classInfo;
        this._methodInfo = method;
    }

    string id() {
        if (_id.empty())
            _id = _messageId.to!string();
        return _id;
    }

    uint messageId() {
        return _messageId;
    }

    Class classInfo() {
        return _classInfo;
    }

    Method methodInfo() {
        return _methodInfo;
    }

    /**
     *
     * Params:
     *   session =
     *   buffer =
     *   args =
     */
    void execute(Args...)(ref TransportContext context, MessageBuffer buffer, Args args) nothrow {
        try {
            string objectKey = id();
            TransportSession session = context.session();
            Object obj = session.getAttribute(objectKey);
            if (obj is null) {
                obj = _classInfo.create();
                session.setAttribute(objectKey, obj);
            }
            _methodInfo.invoke(obj, context, buffer);
        } catch (Throwable ex) {
            warning(ex);
        }
    }
}
