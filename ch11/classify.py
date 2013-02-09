import pymongo
from datetime import datetime
from flask import Flask, request

conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
from_to_reply_ratios = db['from_to_reply_ratios']
hourly_from_reply_probs = db['hourly_from_reply_probs']
p_sent_from_to = db['p_sent_from_to']
overall_reply_ratio = db['overall_reply_ratio']

app = Flask(__name__)

# Controller: Fetch an email and display it
@app.route("/will_reply/")
def will_reply():
  froms = request.args.get('from')
  to = request.args.get('to')
  
  hour = request.args.get('hour') or datetime.time(datetime.now()).hour
  int_hour = int(hour)
  if int_hour < 10:
    hour = "0" + str(int_hour)
  else:
    hour = str(int_hour)
  print "HOUR: |" + str(int_hour) + "|" + hour + "|"
  
  p_from_to_reply = from_to_reply_ratios.find_one({'from': froms, 'to': to})['ratio']
  p_from_hour = hourly_from_reply_probs.find_one({'address': froms})['sent_distribution'][int_hour]['p_reply']

  result = p_from_hour * .5 + p_from_to_reply * .5
  
  print result
  return str(result)

if __name__ == "__main__":
  app.run(debug=True)