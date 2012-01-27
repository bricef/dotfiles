#!/usr/bin/env python

import re
import urllib2
import datetime
import pickle
import os.path

import matplotlib.dates as mpld
from pylab import figure, show

DATAFILE = "/home/bfer/public_html/agile/bugcount.pickle"
GRAPHFILE = "/home/bfer/public_html/agile/bugcount.png"


bug_queries=[
  ("trivial",  "#48ff00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=trivial&format=csv"),
  ("minor",    "#c8ff00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=minor&format=csv"),
  ("major",    "#ffbb00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=major&format=csv"),
  ("critical", "#ff0000", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=critical&format=csv")
]


def get_today(queries):
  """ Get the latest figures for a set of queries"""
  queues={}
  for name, color, url in queries:
    queues[name] = len(urllib2.urlopen(url).read().split("\n"))-2
  queues["total"] = sum(queues.values())
  today = datetime.date.today()
  return (today, queues)

def log_to_file(datum, file):
  """ Logs a datapoint to the file.
      Rewrites the last entry if the last entry is also from today.
      Returns the log with the new entry.
  """
  if os.path.isfile(DATAFILE):
    try:
      log =  pickle.load(open(DATAFILE, "r"))
    except EOFError as err:
      log = []
  else:
    log=[]
  if (len(log)>0) and  (log[-1][0] == datum[0]):
    log[-1] = datum
  else:
    log.append( datum )
  pickle.dump(log, open(file, "w") )
  return log


def graph_data(data, queries, file=GRAPHFILE, showfig=False):
  fig = figure()
  ax = fig.add_subplot(111)
  dates = map(lambda x: x[0], log)
  previous_queue = [0]*len(dates)
  for key, color, url in queries:
    queue = map(sum, zip(previous_queue, map(lambda x: x[1][key], log)))
    ax.plot(dates, queue, color=color)
    ax.fill_between(dates, queue, previous_queue, color=color)
    previous_queue = queue
  fig.autofmt_xdate()
  fig.savefig(file)
  if showfig:
    show()

log = log_to_file(get_today(bug_queries), DATAFILE)
graph_data(log, bug_queries)

