module msgtrans.MessageBuffer;

import std.format;

/** 
 * 
 */
class MessageBuffer
{
    uint id;
    ubyte[] data;

    this(uint id, ubyte[] data) {
        this.id = id;
        this.data = data;
    }

    override string toString() {
        return format("id: %d, length: %d", id, data.length);
    }
}
