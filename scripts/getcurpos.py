#!/usr/bin/env python2
# uses the package python-xlib
# from http://snipplr.com/view/19188/mouseposition-on-linux-via-xlib/

from Xlib import display
import sys

def mousepos():
    data = display.Display().screen().root.query_pointer()._data
    return data["root_x"], data["root_y"]

if __name__ == "__main__":
    x,y=mousepos()
    if (sys.argv[1] == "-x"):
      print("%d"%x)
    elif (sys.argv[1] == "-y"):
      print("%d"%y)
