import sys
import socket
import string
import time

HOST="engbot"
PORT=6667
NICK="loggly"
IDENT="loggly"
REALNAME="logglybot"
readbuffer=""

s=socket.socket( )
s.connect((HOST, PORT))
s.send("USER %s %s bla :%s\r\n" % (IDENT, HOST, REALNAME))
s.send("NICK %s\r\n" % NICK)
time.sleep(2)
s.send("JOIN #eng \r\n")

while 1:
    readbuffer=readbuffer+s.recv(2048)
    temp=string.split(readbuffer, "\n")
    readbuffer=temp.pop( )

    for line in temp:
        line=string.rstrip(line)
        print line
        line=string.split(line)
        if(line[0]=="PING"):
            s.send("PONG %s\r\n" % line[1])
