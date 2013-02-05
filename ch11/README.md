Agile Data the Book
===================

You can buy the book [here](http://shop.oreilly.com/product/0636920025054.do). You can read the book on [O'Reilly OFPS](http://ofps.oreilly.com/titles/9781449326265/) now. Work the chapter code examples as you go. Don't forget to initialize your python environment. Try linux (apt-get, yum) or OS X (brew, port) packages if any of the requirements don't install in your [virtualenv](http://www.virtualenv.org/en/latest/).

Agile Data - Chapter 11: Driving Actions
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

## Calculate Reply Probability for From/To Pairs ##

To calculate, run:

```
pig -l /tmp -x local -v -w p_reply_given_from_to.pig
```

## Calculate Reply Probability by Time of Email Sent ##

To calculate and fill in empty zeros, run:

```
pig -l /tmp -x local -v -w p_reply_given_time_of_day.pig
```

To smooth this data using the Hamming distribution, run:

```
pig -l /tmp -x local -v -w smooth_times.pig
```

Which uses `hamming.py` to and Pig streaming to smooth the email sent distribution using the Hamming distribution.

This will create a mongodb store: 'mongodb://localhost/agile_data.related_addresses'

## Check MongoDB for P(reply|from&to) ##

Run 'mongo.js', or in the mongo terminal:

```
mongo agile_data
db..ensureIndex({from: 1, to: 1});
db..findOne();
```

