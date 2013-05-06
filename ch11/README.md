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

## Calculate Reply Probability by Token - P(reply|token)##

To calculate and fill in empty zeros in the distributions, run:

```
pig -l /tmp -x local -v -w p_reply_given_topics.pig
```

To publish this data, run:

```
pig -l /tmp -x local -v -w publish_topics_.pig
```

This will create a mongodb store: 'mongodb://localhost/agile_data.token_reply_rates_'

## Check MongoDB for P(reply|token) ##

Run 'mongo.js', or in the mongo terminal:

```
mongo agile_data
db.token_reply_rates.ensureIndex({token: 1});
db.token_reply_rates.findOne();
{
	"_id" : ObjectId("511700c330048b60597e7c04"),
	"token" : "public",
	"reply_rate" : 0.6969366812896153
}
db.p_token.ensureIndex({'token': 1})
db.p_token.findOne();
> db.p_token.findOne({'token': 'public'});
{
	"_id" : ObjectId("518444db3004f7fadcb595d9"),
	"token" : "public",
	"prob" : 0.00041651697680944406
}
```

## Deploy Classifier ##

Run index.py to deploy classifier web service against MongoDB probability tables:

```
python ./index
```

To check it, enter well-known values for your own inbox as query parameters to `/will_reply`:

```
curl http://localhost:5000/will_reply?from=russell.jurney@gmail.com&to=*@****.com&message_body=hadoop
```
