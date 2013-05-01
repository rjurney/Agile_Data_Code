import pymongo
from flask import Flask, request
from nltk.tokenize import word_tokenize

conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
from_to_reply_ratios = db['from_to_reply_ratios']
token_reply_rates = db['token_reply_rates']
token_no_reply_rates = db['token_no_reply_rates']

app = Flask(__name__)

# Controller: Fetch an email and display it
@app.route("/will_reply/")
def will_reply():
  
  # Get the message_id, from, first to, and message body
  message_id = request.args.get('mesage_id')
  froms = request.args.get('from')
  to = request.args.get('to')
  body = request.args.get('body')
  
  # For each token in the body, if there's a match in MongoDB, 
  # append it and average all of them at the end
  reply_probs = []
  reply_rate = 1
  no_reply_probs = []
  no_reply_rate = 1
  if(body):
    for token in word_tokenize(body):
      reply_search = token_reply_rates.find_one({'token': token})
      no_reply_search = token_no_reply_rates.find_one({'token': token})
      if reply_search:
        reply_probs.append(reply_search['reply_rate'])
      if no_reply_search:
        no_reply_probs.append(no_reply_search['reply_rate'])
    reply_ary = float(len(reply_probs))
    reply_rate = sum(reply_probs) / len(reply_probs)
    no_reply_ary = float(len(no_reply_probs))
    no_reply_rate = sum(no_reply_probs) / len(no_reply_probs)
  
  # Use from/to probabilities when available
  ftrr = from_to_reply_ratios.find_one({'from': froms, 'to': to})
  if ftrr:
    print ftrr
    p_from_to_reply = ftrr['ratio']
  else:
    p_from_to_reply = 1.0
  
  # Combine the two preditions, equally weighted
  positive = reply_rate * p_from_to_reply
  negative = no_reply_rate * p_from_to_reply
  return str(positive) + ":" + str(negative)

if __name__ == "__main__":
  app.run(debug=True)