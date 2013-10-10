Agile Data the Book
===================

You can buy the book [here](http://shop.oreilly.com/product/0636920025054.do). You can read the book on [O'Reilly OFPS](http://ofps.oreilly.com/titles/9781449326265/) now. Work the chapter code examples as you go. Don't forget to initialize your python environment. Try linux (apt-get, yum) or OS X (brew, port) packages if any of the requirements don't install in your [virtualenv](http://www.virtualenv.org/en/latest/).

Agile Data - Chapter 8: Making Predictions
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
pig -l /tmp -x local -v -w p_reply.pig
```

This will create a mongodb store: 'mongodb://localhost/agile_data.related_addresses'

## Check MongoDB for P(reply|from) and P(reply|to) ##

Run 'mongo.js', or in the mongo terminal:

```
mongo agile_data
db.reply_ratios.ensureIndex({from: 1, to: 1});
db.reply_ratios.findOne();
```

