import pymongo

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
addresses_per_email = db['']

address_lists = addresses_per_email.find()[0:20]
for addresses in address_lists:
  print addresses
