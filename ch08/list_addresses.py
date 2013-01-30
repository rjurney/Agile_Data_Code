import pymongo

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
addresses_per_email = db['addresses_per_email']

address_lists = addresses_per_email.find()[0:20]
for addresses in address_lists:
  print addresses

emails_per_address = db['emails_per_address']
email_list = emails_per_address.find_one()
for email in email_list:
  print email
