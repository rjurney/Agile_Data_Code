from flask import Flask, render_template
import pymongo
import json
import re

# Setup Flask
app = Flask(__name__)

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data

# Fetch from/to totals and list them
@app.route("/sent_counts")
def sent_counts():
  sent_counts = db['sent_counts'].find()
  results = {}
  results['keys'] = 'from', 'to', 'total'
  results['values'] = [[s['from'], s['to'], s['total']] for s in sent_counts if re.search('apache', str(s['from'])) or re.search('apache', str(s['to']))]
  results['values'] = results['values'][0:17]
  return render_template('table.html', results=results)

if __name__ == "__main__":
  app.run(debug=True)
