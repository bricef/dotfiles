#!/usr/bin/env python

import re
import sys
import urllib2
import datetime
import pickle
import os.path

import matplotlib.dates as mpld
from pylab import figure, show
from matplotlib.patches import Rectangle



bug_count = {
  "file"    : "/home/bfer/public_html/agile/bugcount.pickle",
  "graph"   : "/home/bfer/public_html/agile/bugcount.png",
  "queries" : [
    ("trivial",   "#48ff00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=trivial&format=csv"),
    ("minor",     "#c8ff00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=minor&format=csv"),
    ("major",     "#ffbb00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=major&format=csv"),
    ("critical",  "#ff0000", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=critical&format=csv")
  ]
}

bug_state = {
  "file"    : "/home/bfer/public_html/agile/bugstate.pickle",
  "graph"   : "/home/bfer/public_html/agile/bugstate.png",
  "queries" : [
    ("verified",  "#501EE7", "http://trac/bugs/query?status=verified&format=csv"),
    ("closed",    "#abcdef", "http://trac/bugs/query?status=closed&format=csv"),
    ("assigned",  "#123456", "http://trac/bugs/query?status=assigned&format=csv"),  
    ("new",       "#B00B00", "http://trac/bugs/query?status=new&format=csv")
  ]
}


def get_today(queries):
  """ Get the latest figures for a set of queries"""
  queues={}
  for name, color, url in queries:
    queues[name] = len(urllib2.urlopen(url).read().split("\n"))-2
  queues["total"] = sum(queues.values())
  today = datetime.date.today()
  return (today, queues)

class TLog:
  def __init__(self, file):
    self.file = file
    self.log = []
    if os.path.isfile(file):
      try:
        self.log =  pickle.load(open(file, "r"))
      except EOFError as err:
        pass

  def add(self,datum):
    if (len(self.log)>0) and  (self.log[-1][0] == datum[0]):
      self.log[-1] = datum
    else:
      self.log.append( datum )

  def save(self):
    if self.file :
      pickle.dump(self.log, open(self.file, "w") )


def graph_data(data, queries, file=None, showfig=False):
  fig = figure()
  ax = fig.add_subplot(111)
  dates = map(lambda x: x[0], data)
  previous_queue = [0]*len(dates)
  
  labels=[]
  handles=[]
  for key, color, url in queries:
    queue = map(sum, zip(previous_queue, map(lambda x: x[1][key], data)))
    ax.plot(dates, queue, color=color, label="%s"%(key))
    ax.fill_between(dates, queue, previous_queue, color=color)
    handles.append(Rectangle((0,0), 1, 1, fc=color))
    labels.append(key)
    previous_queue = queue
  fig.autofmt_xdate()
  ax.legend(reversed(handles), reversed(labels), loc=2)
  
  if file:
    fig.savefig(file)
  if showfig:
    show()

def display(query):
  log = TLog(query["file"])
  graph_data(log.log, query["queries"], showfig=True)
  
def update(query):
  log = TLog(query["file"])
  log.add(get_today(query["queries"])) 
  graph_data(log.log, query["queries"], file=query["graph"])
  log.save()

if __name__ == "__main__":
  if (len(sys.argv) > 1):
    if sys.argv[1] == "--show":
 #     display(bug_count)
      display(bug_state)
    else:
      print("NOOP")
  else:
    update(bug_count)
    update(bug_state)
      

