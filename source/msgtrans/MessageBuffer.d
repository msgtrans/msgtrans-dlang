module msgtrans.MessageBuffer;

import std.format;

class MessageBuffer
{
    size_t id;
    ubyte[] data;

    this(size_t id, ubyte[] data) {
        this.id = id;
        this.data = data;
    }

    override string toString() {
        return format("id: %d, length: %d", id, data.length);
    }
}
