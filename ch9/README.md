Agile Data - Chapter 9: Building Reports
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

## Calculate Related Email Addresses ##

To calculate something top email addresses, run:
```
pig -l /tmp -x local -v -w related_email_addresses.pig
```

This will create a mongodb store: 'mongodb://localhost/agile_data.related_addresses'

## Check MongoDB for Related Email Addresses ##

Run 'mongo.js', or in the mongo terminal:

```
mongo agile_data
db.related_addresses.ensureIndex({address: 1});
db.related_addresses.findOne();
```

## Fix Sent Distributions in Pig

In Mongo:

```
use agile_data
db.sent_distributions.drop();
```

Then run pig:

```
pig -l /tmp -x local -v -w ./sent_distributions_fix.pig
```
