#!/usr/bin/env python

# Email links:
# http://code.activestate.com/recipes/473810-send-an-html-email-with-embedded-image-and-plain-t/
# http://stackoverflow.com/questions/920910/python-sending-multipart-html-emails-which-contain-embedded-images
# http://snippets.dzone.com/posts/show/2038

import fileinput
import sys
import re
import datetime
import pprint
import json

import matplotlib as mpl

if len(sys.argv) > 1 and sys.argv[1] == "--save":
  mpl.use("Agg")


  
import matplotlib.pyplot as plt


class UTC(datetime.tzinfo):
    """UTC"""
    def utcoffset(self, dt):
        return datetime.timedelta(0)
    def tzname(self, dt):
        return "UTC"
    def dst(self, dt):
        return datetime.timedelta(0)




def raw2intervals(raw):
  data = sorted(raw, key=lambda datum: datum[0]) 
  intervals = []
  last=None
  for datum in data:
    if last:
      intervals.append((last[0],datum[0], last[1]))
      last = datum
    else:
      last = datum
  return intervals

def intervals2num(intervals):
  taskdir = {}
  for i in intervals:
    if i[2] in taskdir:
      taskdir[i[2]].append((mpl.dates.date2num(i[0]), 
                         mpl.dates.date2num(i[1])-mpl.dates.date2num(i[0]))) 
    else:
      taskdir[i[2]]=[] 
      taskdir[i[2]].append((mpl.dates.date2num(i[0]), 
                         mpl.dates.date2num(i[1])-mpl.dates.date2num(i[0]))) 
  return taskdir

def show_timeline_graph(raw,activities):
  intervals = raw2intervals(raw)
  categories = intervals2num(intervals)
  
  # ====================================================================
  
  fig = plt.figure(figsize=(8,4))
  
  # ====================================================================
  
  ax1 = fig.add_subplot(121)
  height=1.0
  catlabels=[]
  yticks=[]
  for category in categories.keys():
    ax1.broken_barh(categories[category], (height,1.0))
    catlabels.append(category)
    yticks.append(height+0.5)
    height += 1
  ax1.grid(True)
  ax1.set_yticks(yticks)
  ax1.set_yticklabels(catlabels)
  ax1.xaxis.set_major_formatter(mpl.dates.DateFormatter("%H:%M"))
  total = raw[-1][0] - raw[0][0] #timedelta

  # ====================================================================

  times = {}
  for category in categories.keys():
    if category != "@end":
      times[category] = 24.0*sum([span[1] for span in categories[category] ])
  
  total_time = sum( [times[category] for category in times.keys()] )
  
  #aggregate anything that's less than 1%
  misc_total=0.0
  for k,v in times.items():
    if (v/total_time) < 0.01:
      del times[k]
      misc_total += v
  times["Misc"]=misc_total


  #print("total: %f"%(total_time))
  pprint.pprint(times)
  
  # ====================================================================
  
  ax = fig.add_subplot(122)
  ax.pie(times.values(), labels=times.keys())

  # ====================================================================

  fig.text(0.75,0.11, str(total), transform = ax1.transAxes, size="x-large", color="r")
  fig.text(0.75,0.05, "%d:%02d hours"%(total_time, (total_time-int(total_time))*60 ), transform = ax1.transAxes, size="x-large", color="r")
  
  plt.show()

class Mapper:
  def __init__(self, activities):
    self.map = {}
    for canonical, aliass in aliases.items():
      for alias in aliass:
        self.map[re.compile(alias, re.IGNORECASE)]=canonical
    self.checks = self.map.keys()
  def __getitem__(self, key):
    for pattern in self.checks:
      if pattern.match(key.strip()):
        return self.map[pattern]
    return key
  def __contains__(self, key):
    for pattern in self.checks:
      if pattern.match(key.strip()):
        return True
    return False

class InvalidInputException(Exception):
  pass

def extract_start_stop(intervals):
  days = []
  starts = []
  durations = []
  
  last_start = None
  for start, stop, cat in intervals:
    if cat == "@start":
      last_start = start
    if cat == "@end":
      days.append(
        mpl.dates.date2num(last_start.date())
      )
      starts.append(
        (mpl.dates.date2num(last_start) % 1) + int(mpl.dates.date2num(datetime.datetime.now()))
      )
      durations.append(
        mpl.dates.date2num(start)
        - mpl.dates.date2num(last_start)
      )
      last_start=None
    else:
      pass

  return days, starts, durations

def show_span_graph(days, starts, durations):
  
  # ====================================================================
  
  fig = plt.figure(figsize=(8,4))
  
  
  ax = fig.add_subplot(111)
  ax.bar(days, durations, bottom=starts, align="center")

  # ====================================================================
  # height=1.0
  # catlabels=[]
  # yticks=[]
  # for category in categories.keys():
  #   ax1.broken_barh(categories[category], (height,1.0))
  #   catlabels.append(category)
  #   yticks.append(height+0.5)
  #   height += 1
  # ax1.grid(True)
  # ax1.set_yticks(yticks)
  # ax1.set_yticklabels(catlabels)
  # ax1.xaxis.set_major_formatter(mpl.dates.DateFormatter("%H:%M"))
  # total = raw[-1][0] - raw[0][0] #timedelta
  # ====================================================================
 
  ax.xaxis_date()
  ax.yaxis_date()
  ax.figure.autofmt_xdate()
  
  plt.show()


if __name__ == "__main__":
  if len(sys.argv)>1 and sys.argv[1] == "--save": 
    pass

  aliases = {}
  if len(sys.argv) > 1 and sys.argv[1] == "--aliasfile":
    aliases = json.load(open(sys.argv[2]))
  
  amap = Mapper(aliases)

  activities = set()
  raw = []
  for line in fileinput.input("-"):
    m = re.search(r'\[(.*)\]: (.*)', line)
    start = datetime.datetime.strptime(m.group(1), '%Y-%m-%d %H:%M')
    activity = m.group(2)
    raw.append((start,amap[activity]))
    activities.add(amap[activity])
  
  #show_span_graph(*extract_start_stop(raw2intervals(raw)))
  show_timeline_graph(raw, activities)

