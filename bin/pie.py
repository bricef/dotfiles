#!/usr/bin/env python

import json
import matplotlib
import fileinput
from pprint import pprint
import matplotlib.pyplot as plt

def chart(times):
  fig = plt.figure()
  ax = fig.add_subplot(111)
  ax.pie(map(lambda x: x[1], times), labels=map(lambda x: x[0], times) )
  plt.show()


if __name__ == "__main__":
  buffer = []
  for line in fileinput.input():
    buffer.append(line)
  dict = json.loads("\n".join(buffer))
  times = []
  total = 0
  for k,v in dict.items():
    times.append( (k,sum(v)) )
  
  total = sum(map(lambda x: x[1], times))
  
  data = []
  for cat, time in times:
    data.append( ("%s (%d%%)"%(cat, round((time/total)*100)), time) )
  

  pprint(times)
  chart(data)
    

