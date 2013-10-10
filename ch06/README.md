Agile Data the Book
===================

You can buy the book [here](http://shop.oreilly.com/product/0636920025054.do). You can read the book on [O'Reilly OFPS](http://ofps.oreilly.com/titles/9781449326265/) now. Work the chapter code examples as you go. Don't forget to initialize your python environment. Try linux (apt-get, yum) or OS X (brew, port) packages if any of the requirements don't install in your [virtualenv](http://www.virtualenv.org/en/latest/).

Agile Data - Chapter 6: Creating Charts
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

## Calculate Emails per Email Address ##

To create a list of all email message_ids that each email address has been a part of:
```
pig -l /tmp -x local -v -w emails_per_email_address.pig
```

This will create a mongodb store: 'mongodb://localhost/agile_data.emails_per_address'

## Check MongoDB for Emails per Email Address ##

See 'mongo.js'

```
mongo agile_data

db.emails_per_address.ensureIndex({address: 1});
db.emails_per_address.findOne();
{
	"_id" : ObjectId("50f1d8603004db7be38006bb"),
	"address" : "user@pig.apache.org",
	"emails" : [
		{
			"message_id" : "2CC96549-8E00-46BF-998E-5606B6952467@gmail.com",
			"subject" : "Re: Group by with count",
			"date" : "2012-12-27T15:36:58"
		},
		{
			"message_id" : "2CC96549-8E00-46BF-998E-5606B6952467@gmail.com",
			"subject" : "Re: Group by with count",
			"date" : "2012-12-27T15:36:58"
		},
		...
}

db.addresses_per_email.ensureIndex({message_id: 1});
db.addresses_per_email.findOne()
{
	"_id" : ObjectId("50f1d8453004db7be37cffb0"),
	"message_id" : "kl59ip.iuzmp1@",
	"addresses" : [
		{
			"address" : "artifacts@computerhistory.org"
		},
		{
			"address" : "russell.jurney@gmail.com"
		},
		{
			"address" : "russell.jurney@gmail.com"
		}
	]
}
```
## Calculate the Distribution by Hour that Emails are Sent ##

To create a sorted count of the hour of the day that emails are sent by each email address in your inbox:
```
pig -l /tmp -x local -v -w sent_distributions.pig
```

## Check MongoDB for Email Sent Distributions ##

See 'mongo.js'

```
mongo agile_data
db.sent_distributions.ensureIndex({address: 1})
db.sent_distributions.findOne()
{
  "_id" : ObjectId("50f365ba30042ade8f22cb86"),
  "sender_email_address" : "russell.jurney@gmail.com",
  "sent_distribution" : [
    {
      "sent_hour" : "00",
      "total" : NumberLong(435)
    },
    {
      "sent_hour" : "01",
      "total" : NumberLong(307)
    },
    ...
  ]
}
```
