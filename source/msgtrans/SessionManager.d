module msgtrans.SessionManager;

import msgtrans.channel.TransportSession;

interface SessionManager {
    
    ulong genarateId();

    TransportSession get(ulong id);

    TransportSession[] getAll();

    void add(TransportSession session);

    void remove(ulong id);

    void remove(TransportSession session);

    void clear();

    bool exists(uint id);
}
