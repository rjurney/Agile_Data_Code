#!/usr/bin/env python
# Based on http://www.scipy.org/Cookbook/SignalSmooth

import numpy as np
import sys, os

def smooth(data, window_len=5, window='hamming'):
  x = data
  s=np.r_[2*x[0]-x[window_len:1:-1], x, 2*x[-1]-x[-1:-window_len:-1]]
  w = getattr(np, window)(window_len)
  y = np.convolve(w/w.sum(), s, mode='same')
  return y[window_len-1:-window_len+1]

def main():
  for line in sys.stdin:
    email, hour_dist = line.split('\t')
    vals = hour_dist[2:-3].rsplit('),(')
    data = []
    for val in vals:
      hour, p_reply = val.rsplit(',')
      data.append(float(p_reply))
    smoothed = smooth(np.array(data)).flatten()
    for i in range(0,len(smoothed)):
      hour = vals[i].rsplit(',')[0]
      print email + "\t" + hour + "\t" + str(smoothed[i])

if __name__ == "__main__":
    main()
