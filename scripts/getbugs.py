#!/usr/bin/env python

import re
import urllib2
import xml.etree.ElementTree as ET

FEEDURL = "http://trac/bugs/query?status=new&status=assigned&status=reopened&format=rss&owner=bfer&order=priority"

try:
  feed = ET.parse(urllib2.urlopen(FEEDURL))
  bugs = feed.find("channel").findall("item")

  for bug in bugs:
    title = re.sub(r'#', r'&#35;', bug.findtext("title"))
    desc  = bug.findtext("description")
    link  = bug.findtext("link")
    print("* [%s](%s)"%(title,link))


except RuntimeError:
  print("Error Occured. Could not retrieve or parse the RSS feed.")
