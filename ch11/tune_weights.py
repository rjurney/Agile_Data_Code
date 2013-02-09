import pymongo
from datetime import datetime
from avro import schema, datafile, io
import pprint
import sys
import json

import dateutil.parser

pp = pprint.PrettyPrinter()

conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
from_to_reply_ratios = db['from_to_reply_ratios']
hourly_from_reply_probs = db['hourly_from_reply_probs']

# Test reading avros
rec_reader = io.DatumReader()
# Create a 'data file' (avro file) reader
df_reader = datafile.DataFileReader(
  open("/me/Data/test_mbox/part-1.avro"),
  rec_reader
)

for record in df_reader:
  message_id = record['message_id']
  froms = record['from']['address']
  if record['tos']:
    if record['tos'][0]:
      to = record['tos'][0]['address']
  datestring = record['date']
  date = dateutil.parser.parse(datestring)
  int_hour = date.hour
  hour = None
  if int_hour < 10:
    hour = "0" + str(int_hour)
  else:
    hour = str(int_hour)
  
  ftrr = from_to_reply_ratios.find_one({'from': froms, 'to': to})
  if ftrr:
    p_from_to_reply = ftrr['ratio']
  else:
    continue
  hfrp = hourly_from_reply_probs.find_one({'address': froms})
  if hfrp:
    p_from_hour = hfrp['sent_distribution'][int_hour]['p_reply']
  else:
    continue
  
  for i in [x / 10.0 for x in range(0, 11, 1)]:
    result = (p_from_hour * i) + (p_from_to_reply * (1 - i))
    print message_id + "\t" + str(i) + "\t" + str(1 - i) + "\t" + str(result)
  