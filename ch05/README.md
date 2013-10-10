Agile Data the Book
===================

You can buy the book [here](http://shop.oreilly.com/product/0636920025054.do). You can read the book on [O'Reilly OFPS](http://ofps.oreilly.com/titles/9781449326265/) now. Work the chapter code examples as you go. Don't forget to initialize your python environment. Try linux (apt-get, yum) or OS X (brew, port) packages if any of the requirements don't install in your [virtualenv](http://www.virtualenv.org/en/latest/).

Agile Data - Chapter 5: Collecting and Displaying Atomic Records
===============================================================

## Setup Python Virtual Environment ##

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
pip install -r requirements.txt
```

## Store Emails in MongoDB ##

```
pig -l /tmp -x local -param avros=<my_inbox_download_path> -param mongourl=mongodb://localhost/agile_data.emails -v -w avro_to_mongo.pig
```

## Create the date and message_id indexes in MongoDB ##

```
mongo < list_emails.mongo.js
```

Or paste that file into the mongo shell.

## Access Emails from Python ##

To test the 'pymongo' module by listing emails, run:

```
python ./mongo_list.py
```

## Store Emails in ElasticSearch ##

pig -l /tmp -x local -v -w ./elasticsearch.pig

## Search Emails from Python ##

Test pyelastic and the ElasticSearch query/sort APIs via:

```
python elasticsearch.py
```

## Run Inbox Application ##

Finally, run our Python/Flask web application.

```
python web/index.py
```

