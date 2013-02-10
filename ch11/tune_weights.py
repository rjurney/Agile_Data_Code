import pymongo
from datetime import datetime
from avro import schema, datafile, io
import pprint
import sys
import json
from nltk.tokenize import word_tokenize

import dateutil.parser

pp = pprint.PrettyPrinter()

conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
from_to_reply_ratios = db['from_to_reply_ratios']
hourly_from_reply_probs = db['hourly_from_reply_probs']
token_reply_rates = db['token_reply_rates']

# Test reading avros
rec_reader = io.DatumReader()
# Create a 'data file' (avro file) reader
df_reader = datafile.DataFileReader(
  open("/me/Data/test_mbox/part-1.avro"),
  rec_reader
)

# Go through all the avro emails...
for record in df_reader:
  # Get the message_id, from, first to, and message body
  message_id = record['message_id']
  froms = record['from']['address']
  if record['tos']:
    if record['tos'][0]:
      to = record['tos'][0]['address']
  
  # For each token in the body, if there's a match in MongoDB, 
  # append it and average all of them at the end
  word_probs = []
  body = record['body']
  for token in word_tokenize(body):
    search = token_reply_rates.find_one({'token': token})
    if search:
      word_probs.append(search['reply_rate'])
  len_probs = float(len(probs))
  if(len_probs > 0):
    token_rate = sum(probs) / len_probs
  else:
    continue
  
  # Use from/to probabilities when available
  ftrr = from_to_reply_ratios.find_one({'from': froms, 'to': to})
  if ftrr:
    p_from_to_reply = ftrr['ratio']
  else:
    continue
  
  # Now try 0.1 increments of weights between these two vectors to weight them
  for i in [x / 10.0 for x in range(0, 11, 1)]:
    result = (token_rate * i) + (p_from_to_reply * (1 - i))
    print message_id + "\t" + str(i) + "\t" + str(1 - i) + "\t" + str(result)

# Tada - followup with test_results.pig to find proper weight. Zoom in more as needed.
