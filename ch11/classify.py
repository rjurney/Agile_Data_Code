import pymongo
import numpy as np
from datetime import datetime
from flask import Flask, request

conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
from_to_reply_ratios = db['from_to_reply_ratios']
hourly_from_reply_probs = db['hourly_from_reply_probs']
p_sent_from_to = db['p_sent_from_to']

app = Flask(__name__)

# Controller: Fetch an email and display it
@app.route("/will_reply/")
def will_reply():
  froms = request.args.get('from')
  to = request.args.get('to')
  hour = request.args.get('hour') or datetime.time(datetime.now()).hour
  int_hour = int(hour)
  hour = "0" + str(int_hour) if hour < 10 else str(int_hour)
  p_from_to = from_to_reply_ratios.find_one({'from': froms, 'to': to})
  answer1 = p_from_to['ratio']
  p_from_hour = hourly_from_reply_probs.find_one({'address': froms})
  answer2 = p_from_hour['sent_distribution'][int_hour]['p_reply']
  return str(answer1 * answer2)

if __name__ == "__main__":
  app.run(debug=True)