#!/usr/bin/env python

import sys
from socket import gethostbyaddr, herror

def usage():
  print("[usage]: %s [ip]"%(sys.argv[0]))
  print("")
  print("performs a reverse lookup on a host ip.")

if __name__ == "__main__":
  if len(sys.argv) > 1 :
    try:
      print("name = %s"%gethostbyaddr(sys.argv[1])[0])    
    except herror:
      print("NOT FOUND")
  else:
    usage()

