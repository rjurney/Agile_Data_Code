Agile Data the Book
===================

You can buy the book [here](http://shop.oreilly.com/product/0636920025054.do). You can read the book on [O'Reilly OFPS](http://ofps.oreilly.com/titles/9781449326265/) now. Work the chapter code examples as you go. Don't forget to initialize your python environment. Try linux (apt-get, yum) or OS X (brew, port) packages if any of the requirements don't install in your [virtualenv](http://www.virtualenv.org/en/latest/).

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

To calculate top email addresses, run:

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

## Fix Sent Distributions in Pig ##

In Mongo:

```
use agile_data
db.sent_distributions.drop();
```

Then run pig:

```
pig -l /tmp -x local -v -w ./sent_distributions_fix.pig
```

## Extract Topics per Email and per Address ##

To calculate TF-IDF scores, run:

```
cd pig
pig -l /tmp -x local -v -w topics.pig
```

To process topic scores into topics per email, run:

```
cd pig
pig -l /tmp -x local -v -w process_topics.pig
```

To publish topics per email message to MongoDB, run:

```
cd pig
pig -l /tmp -x local -v -w publish_topics.pig
```

## Verify Topics in MongoDB ##

In Mongo:

```
use agile_data
db.topics_per_email.ensureIndex({'message_id': 1});
db.topics_per_email.findOne();
db.topics_per_email.findOne();
{
	"_id" : ObjectId("5107216e30043c976eeef513"),
	"message_id" : "B18C58FF-6313-4EAD-B05B-EFD586579D53@hortonworks.com",
	"topics" : [
		{
			"word" : "PIG-3108",
			"score" : 0.13435072789298896
		},
		{
			"word" : "branches",
			"score" : 0.11281142249746937
		}
	]
}
```