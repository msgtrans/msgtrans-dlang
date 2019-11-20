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

module msgtrans.PacketParser;

import hunt.collection.ByteBuffer;
import hunt.collection.BufferUtils;
import hunt.collection.List;
import hunt.collection.ArrayList;

// import hunt.collection.StringBuffer;

import hunt.logging.ConsoleLogger;
import hunt.util.Serialize;

import msgtrans.MessageBuffer;
import msgtrans.PacketHeader;

import std.algorithm : max, canFind;


/** 
 * 
 */
class PacketParser {
    private ByteBuffer _receivedPacketBuf;
    private size_t _defaultBufferSize = 8*1024;

    this(size_t bufferSize = 8*1024) {     
        _defaultBufferSize = bufferSize;
    }

    private void mergeBuffer(ByteBuffer now) {
        // int remaining = 0;
        // if(_receivedPacketBuf !is null)
        //     remaining = _receivedPacketBuf.remaining();
            
        // if(remaining == 0) {
        //     _receivedPacketBuf = buffer;
        // } else {
        //     size_t newPosition = _receivedPacketBuf.position() + buffer.remaining();
        //     infof("buffer: %d", buffer.remaining());
        //     infof("last buffer: %d, newPosition=%d, %s", _receivedPacketBuf.remaining(), newPosition, _receivedPacketBuf.toString());
        //     if(newPosition > _receivedPacketBuf.capacity()) {
        //         size_t newLength = max(newPosition, _defaultBufferSize);
        //         warningf("reset buffer to: %d", newLength);
        //         ByteBuffer tempBuffer = BufferUtils.allocate(cast(int)newLength);
        //         tempBuffer.put(_receivedPacketBuf);
        //         _receivedPacketBuf = tempBuffer;
        //     }
            
        //     _receivedPacketBuf.put(buffer);
        //     trace(_receivedPacketBuf.toString());
        //     _receivedPacketBuf.flip();
        // }
        
        // trace(_receivedPacketBuf.toString());

        if (_receivedPacketBuf !is null) {
            if (_receivedPacketBuf.hasRemaining()) {
                version(HUNT_MESSAGE_DEBUG) {
                    tracef("merge buffer -> %s, %s", _receivedPacketBuf.remaining(), now.remaining());
                }
                ByteBuffer ret = newBuffer(_receivedPacketBuf.remaining() + now.remaining());
                ret.put(_receivedPacketBuf).put(now).flip();
                _receivedPacketBuf = ret;
            } else {
                version(HUNT_MESSAGE_DEBUG) {
                    tracef("buffering data: %s, bytes, current buffer: %s", 
                        now.toString(), _receivedPacketBuf.toString());
                }

                if(now.remaining() <= _receivedPacketBuf.remaining()) {
                    _receivedPacketBuf.clear();
                    _receivedPacketBuf.put(now).flip();
                } else {
                    ByteBuffer ret = newBuffer(now.remaining());
                    ret.put(now).flip();
                    _receivedPacketBuf = ret;
                }
            }
        } else {
            version(HUNT_MESSAGE_DEBUG) tracef("buffering data: %d, bytes", now.remaining());
            // ByteBuffer ret = newBuffer(now.remaining());
            // ret.put(now).flip();
            // _receivedPacketBuf = ret;
            _receivedPacketBuf = now;
        }
        version(HUNT_MESSAGE_DEBUG) trace(_receivedPacketBuf.toString());        
    }

    protected ByteBuffer newBuffer(int size) {
        return BufferUtils.allocate(size);
    }

    MessageBuffer[] parse(ByteBuffer buffer) {
        // TODO: Tasks pending completion -@zhangxueping at 2019-11-13T10:07:54+08:00
        // To handle big size frame

        version(HUNT_DEBUG) tracef("incoming buffer: %s", buffer);
        mergeBuffer(buffer);
        
        MessageBuffer[] resultBuffers;
        size_t dataStart = 0;

        while (_receivedPacketBuf.remaining() >= PACKET_HEADER_LENGTH)
        {
            ubyte[] data = cast(ubyte[])_receivedPacketBuf.getRemaining();
            PacketHeader header = PacketHeader.parse(data);
            if(header is null) {
                warning("corrupted data");
                version(HUNT_DEBUG) {
                    if(data.length<=64)
                        infof("%(%02X %)", data[0 .. $]);
                    else
                        infof("%(%02X %) ...", data[0 .. 64]);
                }
                _receivedPacketBuf.clear(); // All buffered data will be dropped.
                _receivedPacketBuf.flip();
                version(HUNT_MESSAGE_DEBUG) {
                    tracef("_receivedPacketBuf: %d, %s",
                     _receivedPacketBuf.remaining(), _receivedPacketBuf.toString());
                }
                return null;

            // TODO: Tasks pending completion -@zhangxueping at 2019-11-20T14:11:22+08:00
            // 
            // } else if(!avaliableMessageIds.canFind(header.messageId())) {
            //     warningf("Unrecognized packet: %s", header.toString());
            //     _receivedPacketBuf.clear(); 
            //     return null;
            }

            version(HUNT_DEBUG) infof("packet header, %s", header.toString());

            size_t currentFrameSize = header.messageLength + PACKET_HEADER_LENGTH;
            if (data.length < currentFrameSize) {
                // No enough data for a full frame, so save the remaining
                break;
            } else if(data.length > MAX_PACKET_SIZE) {
                warningf("Out of packet size (<= %d): %d", MAX_PACKET_SIZE, currentFrameSize);
                return null;
            }

            resultBuffers ~= new MessageBuffer(header.messageId(), data[PACKET_HEADER_LENGTH..currentFrameSize]);
            version(HUNT_MESSAGE_DEBUG) trace(_receivedPacketBuf.toString());
            _receivedPacketBuf.nextGetIndex(cast(int)currentFrameSize);
            version(HUNT_MESSAGE_DEBUG) trace(_receivedPacketBuf.toString());
        } 
        
        int remaining = _receivedPacketBuf.remaining(); // version(HUNT_MESSAGE_DEBUG) 
        version(HUNT_MESSAGE_DEBUG) tracef("remaining: %d, buffer: %s", remaining, _receivedPacketBuf.toString());
        if(remaining > 0) {
            byte[] data = cast(byte[])_receivedPacketBuf.getRemaining();
            size_t newLength = max(remaining, _defaultBufferSize);
            if(_receivedPacketBuf is buffer || newLength > _receivedPacketBuf.capacity()) {
                version(HUNT_DEBUG) infof("reset buffer's size to %d bytes", newLength);
                _receivedPacketBuf = BufferUtils.allocate(cast(int)newLength);
                _receivedPacketBuf.put(data.dup); // buffer the remaining
                version(HUNT_MESSAGE_DEBUG) trace(_receivedPacketBuf.toString());
                _receivedPacketBuf.flip();
                version(HUNT_MESSAGE_DEBUG) trace(_receivedPacketBuf.toString());
            } else if(resultBuffers.length > 0) {
                warning("buffer the remaining: %s", _receivedPacketBuf.toString());
                _receivedPacketBuf.rewind();
                
                _receivedPacketBuf.put(data.dup); // buffer the remaining
                version(HUNT_MESSAGE_DEBUG) trace(_receivedPacketBuf.toString());
                _receivedPacketBuf.flip();
                version(HUNT_MESSAGE_DEBUG) trace(_receivedPacketBuf.toString());
            } else {
                warning("do nothing");
            }
        } else {
            _receivedPacketBuf = null;
        }
        
        return resultBuffers;
    }
}
