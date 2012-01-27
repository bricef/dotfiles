#!/usr/bin/env python


import fileinput
import re
import datetime
import pprint

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

def showgraph(raw,activities):
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
  
  print("total: %f"%(total_time))
  pprint.pprint(times)
  
  # ====================================================================
  
  ax = fig.add_subplot(122)
  ax.pie(times.values(), labels=times.keys())

  # ====================================================================

  fig.text(0.75,0.11, str(total), transform = ax1.transAxes, size="x-large", color="r")
  fig.text(0.75,0.05, "%d:%d hours"%(total_time, (total_time-int(total_time))*60 ), transform = ax1.transAxes, size="x-large", color="r")
  
  plt.show()





times = {
 'BUGFIXING': 44.2,
 '@misc':25.0,
 '@meeting': 21.7,
 '@slack': 15.0,
 '@tooling': 4.4,
 'WIN EMS': 35.7,
 'Mock SNMP': 65.71666665840894,
 'ADMIN': 8.5
}

showgraph(raw, activities)

