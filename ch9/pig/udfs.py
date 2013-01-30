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

import re

@outputSchema("token:chararray")
def remove_punctuation(token):
  punctuation = re.compile(r'[-.@&$#`\'?!,></\\":;()|]')
  words = list()
  word = punctuation.sub("", token)
  return word
