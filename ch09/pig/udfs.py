@outputSchema("sent_dist:bag{t:(sent_hour:chararray, total_replies:long, total_sent:long)}")
def fill_in_blanks(sent_dist):
  sys.stderr.write("In Data: " + str(sent_dist))
  out_data = list()
  hours = [ '%02d' % i for i in range(24) ]
  for hour in hours:
    entry = [x for x in sent_dist if x[0] == hour]
    if entry:
      entry = entry[0]
      print entry.__class__
      out_data.append(tuple([entry[0], long(entry[1]), long(entry[2])]))
    else:
      out_data.append(tuple([hour, long(0), long(0)]))
  sys.stderr.write("Out data: " + str(out_data))
  return out_data

@outputSchema("sent_dist:bag{t:(sent_hour:chararray, total:long, all_total:long)}")
def fill_in_blanks_two(sent_dist):
  sys.stderr.write("In Data: " + str(sent_dist))
  out_data = list()
  hours = [ '%02d' % i for i in range(24) ]
  
  all_total = long()
  for entry in sent_dist:
    if entry[2]:
      if entry[2] > 0:
        all_total = entry[2]
        break
  
  for hour in hours:
    entry = [x for x in sent_dist if x[0] == hour]
    if entry:
      entry = entry[0]
      print entry.__class__
      out_data.append(tuple([entry[0], long(entry[1]), long(entry[2])]))
    else:
      out_data.append(tuple([hour, long(0), all_total]))
  sys.stderr.write("Out data: " + str(out_data))
  return out_data

@outputSchema("token:chararray")
def lower(token):
  return token.lower()

import re, sys
import operator

def _dotProduct(vector1, vector2):
  dotProduct = 0
  for i in range(0, len(vector1)):
    p = 0
    if vector1[i][0] != None:
      p = vector1[i][0]
    q = 0
    if vector2[i][0] != None:
      q = vector2[i][0]
    dotProduct += p * q
  return dotProduct

@outputSchema("t:tuple(topic1:chararray, topic2:chararray, cosine_similarity:double)") 
def cosineSimilarity(topic1, vector1, topic2, vector2):
  numerator = _dotProduct(vector1, vector2)
  denominator = _dotProduct(vector1, vector1) * _dotProduct(vector2, vector2)
  result = numerator / denominator
  outTuple = (topic1, topic2, result)
  return outTuple

import sys, math

# Adapted from http://code.activestate.com/recipes/578129-simple-linear-regression/
@outputSchema("t:tuple(a:double, b:double)")
def linear_regression(vector):
  return 0
def slope(xs, ys):
  if(len(xs) != len(ys)):
    print "Xs and Ys must be of same length."
    raise
  if(len(xs) == 0):
    print "Xs and Ys must have len > 0."
    raise
  
  x_mean = float(sum(xs))/len(xs) if len(xs) > 0 else float('nan')
  y_mean = float(sum(ys))/len(ys) if len(ys) > 0 else float('nan')
  
  n = float(len(xs))
  sumX, sumY, sumXY, sumXX, sumYY = 0, 0, 0, 0, 0
  
  for i in range(0,len(xs)):
    sumX  += xs[i]
    sumY  += ys[i]
    sumXY += xs[i] * ys[i]
    sumXX += xs[i] * xs[i]
    sumYY += ys[i] * ys[i]

  denominator = math.sqrt((sumXX - 1/n * sumX**2)*(sumYY - 1/n * sumY**2))
  correlation = (sumXY - 1/n * sumX * sumY)
  correlation /= denominator

  # calculating 'a' and 'b' of y = a + b*x
  b  = sumXY - sumX * sumY / n
  b /= (sumXX - sumX**2 / n)

  a  = sumY - b * sumX
  a /= n
  return (a, b)