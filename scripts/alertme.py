#!/usr/bin/python

# More examples at /usr/share/doc/python-notify/examples

# possible extensions:
#  * remote alerts to a server
#  * force prompt user for ack

import sys
import pynotify
import gtk

def cb(n, action):
  print action
  n.close()

if __name__ == "__main__":
  pynotify.init("Alerter Script")
  n = pynotify.Notification("Requested Alert:", sys.argv[1])
  n.set_urgency(pynotify.URGENCY_CRITICAL)
  helper = gtk.Button()
  icon = helper.render_icon(gtk.STOCK_DIALOG_WARNING, gtk.ICON_SIZE_DIALOG)
  n.set_icon_from_pixbuf(icon)
  n.show()
