Agile Data - Chapter 8: Creating Charts
===============================================================

## Setup Python Virtual Environment ##

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
pip install -r requirements.txt
```

## Calculate Emails per Email Address ##

To create a list of all email message_ids that each email address has been a part of:
```
pig -l /tmp -x local -v -w emails_per_email_address.pig
```

This will create a mongodb store: 'mongodb://localhost/agile_data.emails_per_address'

## Query Emails per Email Address in MongoDB ##

```
mongo agile_data
db.emails_per_address.findOne();
```

## Run Analytic Inbox Application ##

Most of this chapter will involve running our Python/Flask web application.

```
python web/index.py
```

## To run ##