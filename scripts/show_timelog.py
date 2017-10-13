 #!/usr/bin/env python3

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


VERBOSE=True


class UTC(datetime.tzinfo):
    """UTC"""
    def utcoffset(self, dt):
        return datetime.timedelta(0)
    def tzname(self, dt):
        return "UTC"
    def dst(self, dt):
        return datetime.timedelta(0)




def raw2intervals(raw):
  """ returns a list of (start, stop, cat) """
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
    if category != "@end":
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
  for k,v in list(times.items()):
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
  return times

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


class Stats:
  def __init__(self, category):
    self.starts = []
    self.durations = []
    self.days = []
    self.category = category
  def add(self, interval):
    start, stop, cat = interval
    if cat.strip() == self.category:
      self.starts.append(start)
      self.durations.append((stop-start).total_seconds())
      self.days.append(start.date())
      
  

class DayStats:
  def __init__(self):
    self.starts = []
    self.durations = []
    self.ends = []
  def add(self, date, cat):
    tod = mpl.dates.date2num(date) % 1
    if cat.strip() == "@start":
      self.starts.append(tod)
    elif cat.strip() == "@end":
      self.ends.append(tod)
      self.durations.append(tod - self.starts[-1])
  def getstats(self):
    return {
      "start": {
        "N": len(self.starts),
        "avg": "%s" % mpl.dates.num2date(1+(sum(self.starts)/len(self.starts))).time().strftime("%H:%M")
      } if self.starts else None,
      "end": {
        "N": len(self.ends),
        "avg": "%s" % mpl.dates.num2date(1+(sum(self.ends)/len(self.ends))).time().strftime("%H:%M")
      } if self.ends else None,
      "duration": {
        "N": len(self.durations),
        "avg": "%s" % mpl.dates.num2date(1+(sum(self.durations)/len(self.durations))).time().strftime("%H:%M")
      } if self.durations else None
    }

def show_trend_graph(stats):
  fig = plt.figure(figsize=(8,4))
  ax = fig.add_subplot(111)
  ax.plot(stats.days, stats.durations, 'o')
  ax.xaxis_date()
  def formatter(x, pos=None):
    return "%d:%02d"%( x/60.0, x%60.0)
  ax.yaxis.set_major_formatter(mpl.ticker.FuncFormatter(formatter))
  ax.set_title(stats.category)
  ax.set_ylim(0,1800)
  ax.yaxis.set_ticks([0,300,600,900,1200,1500,1800])
  ax.figure.autofmt_xdate()
  plt.show()

if __name__ == "__main__":
  import argparse

  parser = argparse.ArgumentParser(description="Timelog grapher")
  parser.add_argument("--save", action="store_true")
  parser.add_argument("--debug", action="store_true")
  parser.add_argument("--aliasfile")
  group = parser.add_mutually_exclusive_group(required=True)
  group.add_argument("--span", action="store_true")
  group.add_argument("--trend", action="store_true")
  group.add_argument("--timeline", action="store_true")
  group.add_argument("--stats", action="store_true")

  config = parser.parse_args(sys.argv[1:])

  if config.debug:
    VERBOSE=True


  aliases = {}
  if config.aliasfile:
    with open(config.aliasfile) as f:
      aliases = json.load(f)
  
  amap = Mapper(aliases)
  day_stats = DayStats()

  #
  # Parse log
  #
  raw_activities = set()
  raw = []
  for line in fileinput.input("-"):
    m = re.search(r'\[(.*)\]: (.*)', line)
    start = datetime.datetime.strptime(m.group(1), '%Y-%m-%d %H:%M')
    activity = m.group(2)
    day_stats.add(start, activity)
    raw.append((start,activity))
    raw_activities.add(activity)
  
  # We do this before resolving aliases or 
  # @standup might fall down the alias hole...
  if config.trend:
    standup_stats = Stats("@standup")
    map(standup_stats.add ,raw2intervals(raw))
    if VERBOSE:
      pprint.pprint(zip(standup_stats.days,standup_stats.durations))
    show_trend_graph(standup_stats)
  
  #
  # Resolve against aliases.
  resolved = [ (start,amap[activity]) for start,activity in raw]
  resolved_activities = set([activ for start,activ in resolved])
 
   
  if config.span:
    show_span_graph(*extract_start_stop(raw2intervals(resolved)))
  
  if config.timeline:
    show_timeline_graph(resolved, resolved_activities)
  
  if config.stats:
    pprint.pprint(day_stats.getstats())
