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

def daygraph(raw,activities):
  fig = plt.figure()
  ax = fig.add_subplot(111)
  
# print raw

  intervals = raw2intervals(raw)
#  print intervals
  
  categories = intervals2num(intervals)
  print categories
  
  height=1.0
  catlabels=[]
  yticks=[]
  for category in categories.keys():
    ax.broken_barh(categories[category], (height,1.0))
    catlabels.append(category)
    yticks.append(height+0.5)
    height += 1
# catlabels.reverse()
#ax.set_ylim(0,3)
  ax.grid(True)
  ax.set_yticks(yticks)
  ax.set_yticklabels(catlabels)


  ax.xaxis.set_major_formatter(mpl.dates.DateFormatter("%H:%M"))
#  ax.xaxis.set_minor_formatter(None)

  plt.show()

  

date = datetime.datetime(2011,10,25,12,00,00,00,UTC())

print date
print mpl.dates.date2num(date)
print mpl.dates.num2epoch(mpl.dates.date2num(date))


daygraph(raw, activities)

