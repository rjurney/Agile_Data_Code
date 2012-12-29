import pymongo
import json

conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
results = db['sent_counts'].find()
for i in range(0, results.count()): # Loop and print all results
  print results[i]

