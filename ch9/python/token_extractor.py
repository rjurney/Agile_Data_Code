#!/usr/bin/python

from collections import defaultdict
import sys, re
import nltk
import json
import operator

def log(message):
  try:
    sys.stderr.write(__file__ + ": " + message + "\n")
  except:
    sys.stderr.write(message + "\n")

class TokenExtractor:
  
  def lower(self, token):
    return token.lower()
  
  def remove_punctuation(self, token):
    punctuation = re.compile(r'[-.@&$#`\'?!,></\\":;()|]')
    words = list()
    word = punctuation.sub("", token)
    if word != "":
      return word
  
  def short_filter(self, token):
    if len(token) > 2:
      words.append(token)

def main():
  te = TokenExtractor()
  for line in sys.stdin:
    message_id, token = line.split('\t')
    lowers = te.lower(token)
    no_punc = te.remove_punctuation(lowers)
    no_shorts = te.short_filter(no_punc)
    print message_id + "\t" + no_shorts

if __name__ == "__main__":
    main()
