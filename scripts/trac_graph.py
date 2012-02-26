#!/usr/bin/env python

import re
import sys
import urllib2
import datetime
import pickle
import os.path

from functools import partial

reports = {
    "bug_count" : {
        "ymax"    : None,
        "ymin"    : None,
        "file"    : "/home/bfer/public_html/agile/bugcount.pickle",
        "graph"   : "/home/bfer/public_html/agile/bugcount.png",
        "queries" : [
          ("trivial",   "#48ff00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=trivial&type=defect+%28bug%29&format=csv"),
          ("minor",     "#c8ff00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=minor&type=defect+%28bug%29&format=csv"),
          ("major",     "#ffbb00", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=major&type=defect+%28bug%29&format=csv"),
          ("critical",  "#ff0000", "http://trac/bugs/query?status=new&status=assigned&status=reopened&priority=critical&type=defect+%28bug%29&format=csv")
        ]
    },

    "bug_state" : {
        "ymax"    : 4000,
        "ymin"    : 2400,
        "file"    : "/home/bfer/public_html/agile/bugstate.pickle",
        "graph"   : "/home/bfer/public_html/agile/bugstate.png",
        "queries" : [
          ("verified",  "#501EE7", "http://trac/bugs/query?status=verified&format=csv"),
          ("closed",    "#abcdef", "http://trac/bugs/query?status=closed&format=csv"),
          ("assigned",  "#123456", "http://trac/bugs/query?status=assigned&format=csv"),  
          ("new",       "#B00B00", "http://trac/bugs/query?status=new&format=csv")
        ]
    }
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


def graph_data(data, queries, file=None, showfig=False, baseline=None, max=None):
  fig = figure()
  if baseline or max:
    ax = fig.add_subplot(111, autoscaley_on=False)
    ax.set_ylim(ymin=baseline, ymax=max)
  else:
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
  fig.text(0.7,0.25, datetime.datetime.today().strftime("%Y-%m-%d"), size="x-large", color="black")

  if file:
    fig.savefig(file)
  if showfig:
    show()

def display(query):
  log = TLog(query["file"])
  graph_data(log.log, query["queries"], showfig=True, baseline=query["ymin"], max=query["ymax"])
  
def update(query):
  log = TLog(query["file"])
  log.add(get_today(query["queries"])) 
  graph_data(log.log, query["queries"], file=query["graph"], baseline=query["ymin"], max=query["ymax"])
  log.save()

def colorgen():
  colors = ["#ff0000", "#00ff00", "#0000ff"]
  co = 0
  while True:
    yield colors[co % len(colors)]
    co= co+1


def do_csv_input():
  import fileinput
  import csv
  reader = csv.reader(fileinput.input(sys.argv[2]))
  
  headers = reader.next()
  columns = zip(*reader)
  dates = [datetime.datetime.strptime(x, "%Y-%m-%d") for x in columns[0]]
  categories = [
    ("Backlog",         "#dead00", map(int, columns[1])),
    ("Analysis",        "#d00dad", map(sum, zip(map(int, columns[2]), map(int, columns[4])))),
    ("Fix",             "#b00b1e", map(int, columns[3])),
    ("Test Queue",      "#abcdef", map(int, columns[5])),
    ("System Testing",  "#123456", map(int, columns[6])),
    ("Archive",         "#501ee7", map(int, columns[7]))
  ]



   
  fig = figure()
  ax = fig.add_subplot(111)
  colors=colorgen()
  handles = []
  labels = []
  previous_queue = [0]*len(dates)
  for category, color, queue in reversed(categories):
    queue = map(sum, zip(previous_queue, map(int, queue)))
    ax.fill_between(dates, queue, previous_queue, color=color)
    handles.append(Rectangle((0,0),1,1,fc=color))
    labels.append(category)
    previous_queue = queue
  fig.autofmt_xdate()
  box=ax.get_position()
  ax.set_position([box.x0, box.y0, box.width*0.8, box.height])
  ax.legend(reversed(handles), reversed(labels), loc='center left', bbox_to_anchor=(1,0.5))
  show()

    


if __name__ == "__main__":
  graphical = False
  csv_input = False
  if (len(sys.argv) > 1):
    if sys.argv[1] == "--show":
      graphical = True
    elif sys.argv[1] == "--csv":
      csv_input = True

  import matplotlib
  if not graphical and not csv_input:
    matplotlib.use("Agg")
  import matplotlib.dates as mpld
  from pylab import figure, show
  from matplotlib.patches import Rectangle
 

  if csv_input:
    do_csv_input()
  elif graphical:
    for name, report in reports.items():
      display(report)
  else:
    for name, report in reports.items():
      update(report)
    


    


