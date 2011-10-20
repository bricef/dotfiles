#!/usr/bin/env python


import fileinput
import re
import datetime

import matplotlib as mpl
import matplotlib.pyplot as plt


activities = set()
raw = []

# dont plot start/end as bars, instead vertical lines 

for line in fileinput.input():
  m = re.search(r'\[(.*)\]: (.*)', line)
  start = datetime.datetime.strptime(m.group(1), '%Y-%m-%d %H:%M')
  activity = m.group(2)
  raw.append((start,activity))
  activities.add(activity)


def filterfor(activity):
  def filter(item):
    return item is activity


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
  return [ (i[0], i[1]) for i in intervals ]


def daygraph(raw,activities):
  fig = plt.figure()
  ax = fig.add_subplot(111)
  
  print raw

  intervals = raw2intervals(raw)
  print intervals
  
  nums = intervals2num(intervals)
  print nums
  
  ax.broken_barh(nums, (1.0,1.0))
  ax.set_ylim(0,3)
  ax.grid(True)


  ax.xaxis.set_major_formatter(mpl.dates.DateFormatter("%Y-%m"))
#  ax.xaxis.set_minor_formatter(None)

  plt.show()


daygraph(raw, activities)

