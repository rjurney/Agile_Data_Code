# Based on http://www.scipy.org/Cookbook/SignalSmooth

import numpy as np

class Smoother():
  
  """Takes an array of objects as input, and the data key of the object for access."""
  def __init__(self, raw_data, data_key):
    self.raw_data = raw_data
    print self.raw_data
    self.data = self.to_array(raw_data, data_key)
  
  """Given an array of objects with values, return a numpy array of values."""
  def to_array(self, in_data, data_key):
    data_array = list()
    for datum in in_data:
      data_array.append(datum[data_key])
    return np.array(data_array)
  
  """Smoothing method from SciPy SignalSmooth Cookbook: http://www.scipy.org/Cookbook/SignalSmooth"""
  def smooth(self, window_len=5, window='hamming'):
    x = self.data
    s=np.r_[2*x[0]-x[window_len:1:-1], x, 2*x[-1]-x[-1:-window_len:-1]]
    w = getattr(np, window)(window_len)
    y = np.convolve(w/w.sum(), s, mode='same')
    self.smoothed = y[window_len-1:-window_len+1]
  
  def to_objects(self):
    objects = list()
    hours = [ '%02d' % i for i in range(24) ]
    for idx, val in enumerate(hours):
      objects.append({"sent_hour": val, "total": round(self.smoothed[idx], 0)})
    return objects
