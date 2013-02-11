import pymongo
from datetime import datetime
from flask import Flask, request
from nltk.tokenize import word_tokenize

conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
from_to_reply_ratios = db['from_to_reply_ratios']
token_reply_rates = db['token_reply_rates']
overall_reply_ratio = db['overall_reply_ratio']
prior = overall_reply_ratio.find_one({'key': 'overall'})['reply_ratio']

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
  word_probs = []
  if(body):
    for token in word_tokenize(body):
      search = token_reply_rates.find_one({'token': token})
      if search:
        word_probs.append(search['reply_rate'])
    len_probs = float(len(word_probs))
    if(len_probs > 0):
      token_rate = sum(word_probs) / len_probs
    else:
      token_rate = prior
  else:
    token_rate = prior
  
  # Use from/to probabilities when available
  ftrr = from_to_reply_ratios.find_one({'from': froms, 'to': to})
  if ftrr:
    print ftrr
    p_from_to_reply = ftrr['ratio']
  else:
    p_from_to_reply = prior
  result = (token_rate * .5) + (p_from_to_reply * (1 - .5))
  return str(result)

if __name__ == "__main__":
  app.run(debug=True)