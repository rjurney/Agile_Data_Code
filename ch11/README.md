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

## Calculate Reply Probability for From/To Pairs - P(reply|from&to) ##

To calculate, run:

```
pig -l /tmp -x local -v -w p_reply_given_from_to.pig
```

This will create a mongodb store called `from_to_reply_ratios`.

## Check MongODB for P(reply|from & to) ##

Run mongo.js, or in the mongo terminal:
```
use agile_data
db.from_to_reply_ratios.ensureIndex({from: 1, to: 1});
db.from_to_reply_ratios.findOne();
{
	"_id" : ObjectId("5111653f3004769d48b77a5b"),
	"from" : "russell.jurney@gmail.com",
	"to" : "bumper1700@hotmail.com",
	"ratio" : 0.5
}

```

## Calculate Reply Probability by Time of Email Sent- P(reply|from & hour)##

To calculate and fill in empty zeros in the distributions, run:

```
pig -l /tmp -x local -v -w p_reply_given_time_of_day.pig
```

To smooth this data using the Hamming distribution, run:

```
pig -l /tmp -x local -v -w smooth_times.pig
```

Which uses `hamming.py` to and Pig streaming to smooth the email sent distribution using the Hamming distribution.

This will create a mongodb store: 'mongodb://localhost/agile_data.hourly_from_reply_probs'

## Check MongoDB for P(reply|from & hour) ##

Run 'mongo.js', or in the mongo terminal:

```
mongo agile_data
db.hourly_from_reply_probs.ensureIndex({address: 1});
db.hourly_from_reply_probs.findOne();
{
	"_id" : ObjectId("5111644c3004641354d5ee5a"),
	"address" : "russell.jurney@gmail.com",
	"sent_distribution" : [
		{
			"hour" : "00",
			"p_reply" : 0.452386044568
		},
		{
			"hour" : "01",
			"p_reply" : 0.419107010988
		},
    ...
  ]
}
```

## Deploy Classifier ##

Run classify.py to deploy classifier web service against MongoDB probability tables:

```
python ./classify
```

To check it, enter well-known values for your own inbox as query parameters to `/will_reply/`:

```
curl http://localhost:5000/will_reply/?from=russell.jurney@gmail.com&to=p@pstam.com&body=hadoop
```

The result: 83.9376 chance of reply if I email Stammy about Hadoop.
