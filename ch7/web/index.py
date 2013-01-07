from flask import Flask, render_template
import pymongo
import json
import re

# Setup Flask
app = Flask(__name__)

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data

# Fetch an email and display it
@app.route("/email/<message_id>")
def sent_counts(message_id):
  email = db['emails'].find_one({'message_id': message_id})
  return render_template('partials/email.html', email=email)

if __name__ == "__main__":
  app.run(debug=True)
