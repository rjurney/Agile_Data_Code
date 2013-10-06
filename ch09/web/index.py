from flask import Flask, render_template, request
import pymongo
import json, pyelasticsearch
import re
import config
from smoother import Smoother
from nltk.tokenize import word_tokenize

# Setup Flask
app = Flask(__name__)

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
emails = db['emails']
addresses_per_email = db['addresses_per_email']
emails_per_address = db['emails_per_address']
sent_distributions = db['sent_distributions']
related_addresses = db['related_addresses']
topics_per_email = db['topics_per_email']
from_to_reply_ratios = db['from_to_reply_ratios']
from_to_no_reply_ratios = db['from_to_no_reply_ratios']
p_sent_from_to = db['p_sent_from_to']
token_reply_rates = db['token_reply_rates']
token_no_reply_rates = db['token_no_reply_rates']
p_token = db['p_token']

# Setup ElasticSearch
elastic = pyelasticsearch.ElasticSearch(config.ELASTIC_URL)

# Model helper
def get_smoothed_sent_dist(address):
  sent_dist = sent_distributions.find_one({'address': address})
  smitty = Smoother(sent_dist['sent_distribution'], 'total')
  smitty.smooth()
  smoothed_dist = smitty.to_objects()
  return smoothed_dist

# Controller: Fetch an email and display it
@app.route("/email/<message_id>")
def email(message_id):
  email = emails.find_one({'message_id': message_id})
  address_hash = addresses_per_email.find_one({'message_id': message_id})  
  smoothed_dist = get_smoothed_sent_dist(email['from']['address'])
  chart_json = json.dumps(smoothed_dist)  
  topics = topics_per_email.find_one({'message_id': message_id})
  return render_template('partials/email.html', email=email, 
                                                addresses=address_hash['addresses'], 
                                                chart_json=chart_json, 
                                                sent_distribution=smoothed_dist,
                                                topics=topics)
  
# Calculate email offsets for fetchig lists of emails from MongoDB
def get_navigation_offsets(offset1, offset2, increment):
  offsets = {}
  offsets['Next'] = {'top_offset': offset2 + increment, 'bottom_offset': offset1 + increment}
  offsets['Previous'] = {'top_offset': max(offset2 - increment, increment), 'bottom_offset': max(offset1 - increment, 0)} # Don't go < (0,min increment)
  return offsets

# Process elasticsearch hits and return email records
def process_search(results):
  emails = []
  if results['hits'] and results['hits']['hits']:
    hits = results['hits']['hits']
    for hit in hits:
      email = hit['_source']
      emails.append(hit['_source'])
  return emails

# Controller: Fetch a list of emails and display them
@app.route('/')
@app.route('/emails/')
@app.route("/emails/<int:offset1>/<int:offset2>")
def list_emails(offset1 = 0, offset2 = config.EMAILS_PER_LIST_PAGE, query=None):
  query = request.args.get('search')
  if query==None:
    email_list = emails.find()[offset1:offset2]
  else:
    results = elastic.search({'query': {'match': { '_all': query}}, 
                              'sort': {'date': {'order': 'desc'}}, 
                              'from': offset1, 
                              'size': config.EMAILS_PER_LIST_PAGE}, 
                              index="emails")
    email_list = process_search(results)
  nav_offsets = get_navigation_offsets(offset1, offset2, config.EMAILS_PER_LIST_PAGE)
  return render_template('partials/emails.html', emails=email_list, nav_offsets=nav_offsets, nav_path='/emails/', query=query)

# Display sent distributions for a give email
@app.route('/sent_distribution/<string:sender>')
def sent_distribution(sender):
  sent_dist_records = sent_distributions.find_one({'address': sender})
  return render_template('partials/sent_distribution.html', chart_json=json.dumps(sent_dist_records['sent_distribution']), 
                                                            sent_distribution=sent_dist_records)

# Display information about an email address
@app.route('/address/<string:address>')
@app.route('/address/<string:address>/<int:offset1>/<int:offset2>')
def address(address, offset1=0, offset2=config.EMAILS_PER_ADDRESS_PAGE):
  address = address.lower() # In case the email record linking to this isn't lowered... consider ETL on base document in Pig
  emails = emails_per_address.find_one({'address': address})['emails'][offset1:offset2]
  nav_offsets = get_navigation_offsets(offset1, offset2, config.EMAILS_PER_ADDRESS_PAGE)
  addresses = related_addresses.find_one({'address': address})['related_addresses']
  smoothed_dist = get_smoothed_sent_dist(address)
  chart_json = json.dumps(smoothed_dist)
  reply_ratio = db.reply_ratios.find_one({'from': config.MY_EMAIL, 'to': address})
  return render_template('partials/address.html', 
                         emails=emails, 
                         nav_offsets=nav_offsets, 
                         nav_path='/address/' + address + '/', 
                         sent_distribution=smoothed_dist,
                         addresses=addresses,
                         chart_json=chart_json,
                         address='<' + address + '>',
                         reply_ratio=reply_ratio
                         )
                
# Controller: Fetch an email and display it
@app.route("/will_reply")
def will_reply():

  # Get the message_id, from, first to, and message body
  message_id = request.args.get('mesage_id')
  froms = request.args.get('from')
  to = request.args.get('to')
  body = request.args.get('message_body')

  # For each token in the body, if there's a match in MongoDB, 
  # append it and average all of them at the end
  reply_probs = []
  reply_rate = 1
  no_reply_probs = []
  no_reply_rate = 1
  if(body):
    for token in word_tokenize(body):
      
      prior = p_token.find_one({'token': token}) # db.p_token.ensureIndex({'token': 1})
      reply_search = token_reply_rates.find_one({'token': token}) # db.token_reply_rates.ensureIndex({'token': 1})
      no_reply_search = token_no_reply_rates.find_one({'token': token}) # db.token_no_reply_rates.ensureIndex({'token': 1})
      if reply_search:
        word_prob = reply_search['reply_rate'] * prior['prob']
        print("Token: " + token + " Reply Prob: " + str(word_prob))
        reply_probs.append(word_prob)
      if no_reply_search:
        word_prob = no_reply_search['reply_rate'] * prior['prob']
        print("Token: " + token + " No Reply Prob: " + str(word_prob))
        no_reply_probs.append(word_prob)
    reply_ary = float(len(reply_probs))
    reply_rate = sum(reply_probs) / (len(reply_probs) if len(reply_probs) > 0 else 1)
    no_reply_ary = float(len(no_reply_probs))
    no_reply_rate = sum(no_reply_probs) / (len(no_reply_probs) if len(no_reply_probs) > 0 else 1)

  # Use from/to probabilities when available
  ftrr = from_to_reply_ratios.find_one({'from': froms, 'to': to}) # db.from_to_reply_ratios.ensureIndex({from: 1, to: 1})
  ftnrr = from_to_no_reply_ratios.find_one({'from': froms, 'to': to}) # db.from_to_no_reply_ratios.ensureIndex({from: 1, to: 1})
  if ftrr:
    p_from_to_reply = ftrr['ratio']
    p_from_to_no_reply = ftnrr['ratio']
  else:
    p_from_to_reply = 1.0
    p_from_to_no_reply = 1.0

  # Combine the two predictions
  positive = reply_rate * p_from_to_reply
  negative = no_reply_rate * p_from_to_no_reply
  print "%2f vs %2f" % (positive, negative)
  result = "REPLY" if positive > negative else "NO REPLY"

  return render_template('partials/will_reply.html', result=result, froms=froms, to=to, message_body=body)


if __name__ == "__main__":
  app.run(debug=True)
