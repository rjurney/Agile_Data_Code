from flask import Flask, render_template
import pymongo
import json
import re

# Setup Flask
app = Flask(__name__)

# Setup Mongo
conn = pymongo.Connection() # defaults to localhost
db = conn.agile_data
emails = db['emails']

# Fetch an email and display it
@app.route("/email/<message_id>")
def sent_counts(message_id):
  email = emails.find_one({'message_id': message_id})
  return render_template('partials/email.html', email=email)

# Fetch a list of emails and display them
@app.route('/')
@app.route('/emails/')
@app.route("/emails/<int:offset1>/<int:offset2>")
def list_emails(offset1 = 0, offset2 = 17):
  email_list = emails.find()[offset1:offset2]
  data = {'emails': email_list,  'nav_path': '/emails/'} #'nav_offsets': nav_offsets,
  return render_template('partials/emails.html', data=data)

if __name__ == "__main__":
  app.run(debug=True)
