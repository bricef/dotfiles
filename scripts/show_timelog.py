#!/usr/bin/env python


import fileinput
import re
import datetime

import matplotlib as mpl
import matplotlib.pyplot as plt


class UTC(datetime.tzinfo):
    """UTC"""
    def utcoffset(self, dt):
        return datetime.timedelta(0)
    def tzname(self, dt):
        return "UTC"
    def dst(self, dt):
        return datetime.timedelta(0)

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
  return [ (mpl.dates.date2num(i[0]), mpl.dates.date2num(i[1]-i[0]) ) 
            for i in intervals ]


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


#  ax.xaxis.set_major_formatter(mpl.dates.DateFormatter("%Y-%m"))
#  ax.xaxis.set_minor_formatter(None)

  plt.show()

  

date = datetime.datetime(2011,10,25,12,00,00,00,UTC())

print date
print mpl.dates.date2num(date)
print mpl.dates.num2epoch(mpl.dates.date2num(date))


daygraph(raw, activities)

