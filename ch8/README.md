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

## Check MongoDB for Emails per Email Address ##

```
mongo agile_data
db.emails_per_address.findOne();
```
## Calculate the Distribution by Hour that Emails are Sent ##

To create a sorted count of the hour of the day that emails are sent by each email address in your inbox:
```
pig -l /tmp -x local -v -w sent_distributions.pig
```

## Run Analytic Inbox Application ##

Most of this chapter will involve running our Python/Flask web application.

```
python web/index.py
```

## To run ##