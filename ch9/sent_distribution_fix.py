import pymongo

def fill_in_blanks(in_data):
  out_data = list()
  hours = [ '%02d' % i for i in range(24) ]
  for hour in hours:
    entry = [x for x in in_data if x['sent_hour'] == hour]
    if entry:
      out_data.append(entry[0])
    else:
      out_data.append({'sent_hour': hour, 'total': 0})
  return out_data

def address(email_address):
  chart_json = json.dumps(fill_in_blanks(sent_dist['sent_dist']))

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
sent_dist = db['sent_distributions']

record = sent_dist.find_one()
