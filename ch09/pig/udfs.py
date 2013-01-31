@outputSchema("sent_dist:bag{t:(sent_hour:chararray, total:int)}")
def fill_in_blanks(sent_dist):
  print sent_dist
  out_data = list()
  hours = [ '%02d' % i for i in range(24) ]
  for hour in hours:
    entry = [x for x in sent_dist if x[0] == hour]
    if entry:
      entry = entry[0]
      print entry.__class__
      out_data.append(tuple([entry[0], entry[1]]))
    else:
      out_data.append(tuple([hour, 0]))
  return out_data

@outputSchema("token:chararray")
def lower(token):
  return token.lower()

import re, sys

@outputSchema("token:chararray")
def remove_punctuation(token):
  #word = re.sub(r'([^\w\s]|_)+(?=\s|$)', '', token)
  #punctuation = re.compile(r'[-.@&$#`\'?!,></\\":;()|]')
  #words = list()
  #word = punctuation.sub('', token, count=sys.maxint)
  return token

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