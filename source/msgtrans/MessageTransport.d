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

module msgtrans.MessageTransport;

import msgtrans.MessageTransport;
import msgtrans.MessageHandler;
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
    private MessageHandler[uint] _messageHandlers;

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

    void registerHandler(uint msgId, MessageHandler handler) {
        auto itemPtr = msgId in _messageHandlers;
        if(itemPtr is null) {
            _messageHandlers[msgId] = handler;
        } else {
            // throw new Exception(format("Message handler confliction: %d", msgId));
            version(MSGTRANS_DEBUG) {
                warningf("Message handler confliction: %d", msgId);
            }
        }
    }

    void deregisterHandler(uint msgId) {
        auto itemPtr = msgId in _messageHandlers;
        if(itemPtr is null) {
            // throw new Exception(format("No message handler found: %d", msgId));
            version(MSGTRANS_DEBUG) {
                warningf("No message handler found: %d", msgId);
            }
        } else {
            _messageHandlers.remove(msgId);
        }
    }
    
    MessageHandler getMessageHandler(uint id) {
        auto itemPtr = id in _messageHandlers;
        if(itemPtr is null) {
            string msg = format("No message handler found for MessageID %d in peer %s", id, _name);
            version(MSGTRANS_DEBUG) warning(msg);
            return null;
        }
        return *itemPtr;
    }

    ExecutorInfo getExecutor(uint id) {
        auto itemPtr = id in _executors;
        if(itemPtr is null) {
            string msg = format("No message handler found for MessageID %d in server %s", id, _name);
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
struct TransportServer {
    enum NAME_PREFIX = "SERVER-";
    string name;
}

/** 
 * 
 */
struct TransportClient {
    enum NAME_PREFIX = "CLIENT-";
    string name;
}