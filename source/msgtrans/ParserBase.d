module msgtrans.ParserBase;

import msgtrans.EvBuffer;
import hunt.net.Connection;
import msgtrans.MessageBuffer;
import hunt.util.Serialize;
import std.bitmanip;
import std.stdint;
import std.string;
import std.stdio;
import std.conv;
import std.typecons;
import std.uri;

struct HttpContent {
    size_t status = 0;
    string path;
    string method;
    string[string] headField;
    string[string] parameters;
    string body;

    void reset()
    {
        status= 0;
        path = "";
    }
}

enum Field {
    CONTENTLENGTH = "Content-Length"
}

class ParserBase {

    protected enum string CONTEXT = "REVBUFFER";

    private const ulong DATAHEADLEN = 20;

    protected const string HTTPHEADEOF = "\r\n\r\n";
    protected const string LINEFEEDS = "\r\n";

    enum MAX_HTTP_REQUEST_BUFF = 4096;

    public void parserTcpStream (EvBuffer!ubyte src , ubyte [] incr , Connection connection)
    {
        src.mergeBuffer(incr);
        ulong uBufLen = 0;

        while ( (uBufLen = src.getBufferLength()) >= DATAHEADLEN )
        {
            auto head = new ubyte [DATAHEADLEN];
            if (!src.copyOutFromHead(head ,DATAHEADLEN)) { break;}

            ulong bodyLength = bigEndianToNative!int32_t(head[16 .. 20]);

            if (bodyLength > 2147483647 || bodyLength < 0)
            {
                src.reset();
                break;
            }

            if (uBufLen >=  bodyLength + DATAHEADLEN)
            {
                MessageBuffer msg = new MessageBuffer();
                msg.messageId = bigEndianToNative!long(head[8 .. 16]);
                if (!src.drainBufferFromHead(DATAHEADLEN)) { break;}
                msg.message = new ubyte [bodyLength];
                if (bodyLength)
                {
                    if (!src.removeBufferFromHead(msg.message,bodyLength))  {break;}
                }
                if (connection !is null)
                {
                    ConnectionEventHandler handler = connection.getHandler();
                    if(handler !is null) {
                        handler.messageReceived(connection, msg);
                    }
                }
            } else
            {
                break;
            }
        }
    }

    public void parserHttpStream (EvBuffer!ubyte src , ubyte [] incr , Connection connection)
    {
        src.mergeBuffer(incr);
        if (src.getBufferLength() > MAX_HTTP_REQUEST_BUFF)
        {
            src.reset();
            return;
        }

        ulong head_pos = 0 ;
        string buffer = cast(string)src.getBuffer();
        while ((head_pos = indexOf(buffer,HTTPHEADEOF)) != -1)
        {
            HttpContent content;
            string head = cast(string)buffer[0 .. head_pos];
            parserHttpHead(content,head);
            auto content_length = content.headField.get(Field.CONTENTLENGTH,null);
            if (content_length !is null && (head_pos + 4 + to!int(content_length)) > buffer.length)
            {
                break;
            }
            else
            {
                content.body = buffer[head_pos + 4 .. $];
                MessageBuffer msg = new MessageBuffer();
                msg.messageId = cast(int)hashOf!string(content.path);
                msg.message = cast(ubyte[])serialize!HttpContent(content);
                if (connection !is null)
                {
                    ConnectionEventHandler handler = connection.getHandler();
                    if(handler !is null) {
                        handler.messageReceived(connection, msg);
                    }
                }
                src.reset();
                break;
            }
        }
    }

    private void parserHttpHead(ref HttpContent httpcontent , string headBuff)
    {
        auto fields = split(headBuff,"\r\n");
        foreach(field;fields)
        {
            if (field.count("HTTP/"))
            {
                auto child = split(field," ");
                if (child[0].count("HTTP/"))
                {
                    httpcontent.status = to!int(child[1]);

                } else
                {
                    httpcontent.method= child[0];
                    string url = decodeComponent(child[1]);
                    long flag = indexOf(url ,"?");
                    httpcontent.path = url[0 .. flag == -1 ? $:flag];
                    if (flag != -1)
                    {
                        string[] items = url[flag + 1 .. $].split("&");
                        foreach( item ; items)
                        {
                            if(item != string.init)
                            {
                                auto v = item.split("=");
                                httpcontent.parameters[v[0]] = v[1];
                            }
                        }
                    }
                }
            } else
            {
                long pos = 0;
                if ( (pos = indexOf(field ,":")) != -1)
                {
                    httpcontent.headField[strip(field[0 .. pos])] = strip(field[pos+1 ..$]);
                }
            }
        }
    }
}