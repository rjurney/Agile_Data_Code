from flask import Flask
import pymongo
import json

# Setup Flask
app = Flask(__name__)

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
sent_counts = db['sent_counts']

# Fetch from/to totals, given a pair of email addresses
@app.route("/sent_counts/<from_address>/<to_address>")
def sent_count(from_address, to_address):
  sent_count = sent_counts.find_one( {'from': from_address, 'to': to_address} )
  return json.dumps( {'from': sent_count['from'], 'to': sent_count['to'], 'total': sent_count['total']} )

if __name__ == "__main__":
  app.run(debug=True)
