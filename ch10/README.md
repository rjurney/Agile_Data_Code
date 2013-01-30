Agile Data - Chapter 10: Making Predictions
===============================================================

## Setup Python Virtual Environment ##

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
pip install -r requirements.txt
```

## Run Analytic Inbox Application ##

Most of this chapter will involve running our Python/Flask web application.

```
python web/index.py
```

## Smooth Email Sent Time Distributions ##

See previous - start the web app, the fix is applied to 'web/index.py'.

## Calculate Reply Probability ##

To calculate, run:

```
pig -l /tmp -x local -v -w related_email_addresses.pig
```

This will create a mongodb store: 'mongodb://localhost/agile_data.related_addresses'

## Check MongoDB for P(reply|from) and P(reply|to) ##

Run 'mongo.js', or in the mongo terminal:

```
mongo agile_data
db.p_reply_given_from.ensureIndex({address: 1});
db.p_reply_given_from.findOne();
```

