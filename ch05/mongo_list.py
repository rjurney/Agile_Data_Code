import pymongo

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
emails = db['emails']

email_list = emails.find()[0:20]
for email in email_list:
  print email
