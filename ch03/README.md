Agile Data the Book
===================

You can buy the book [here](http://shop.oreilly.com/product/0636920025054.do). You can read the book on [O'Reilly OFPS](http://ofps.oreilly.com/titles/9781449326265/) now. Work the chapter code examples as you go. Don't forget to initialize your python environment. Try linux (apt-get, yum) or OS X (brew, port) packages if any of the requirements don't install in your [virtualenv](http://www.virtualenv.org/en/latest/).

Agile Data - Chapter 3: Agile Tools
=========================================================

## Pre-requisites for Mac OS X (OS X Mavericks)

The following need to be installed before the virtual environment and associated requirement(s) can be installed correctly. If you already have these items installed, please proceed to setup the Python virtual environment. 

```
# Setup ant - Required to compile snappy-c, yaml-c 
brew install ant

# Setup maven - Required to compile Wonderdog
brew install maven

# Setup gfortran - Required to compile SciPy
brew install gfortran
```

## Setup your Python Virtual Environment ##

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
pip install -r requirements.txt
```

## Download your Gmail Inbox! ##

```
# Download your gmail inbox
cd gmail
./gmail.py -m automatic -u me@gmail.com -p 'my_password_' -s ./email.avro.schema -f '[Gmail]/All Mail' -o /tmp/my_inbox_directory 2>&1 &
```

## Download Apache Pig ##
```
wget http://www.trieuvan.com/apache/pig/pig-0.10.1/pig-0.10.1.tar.gz
tar -xvzf pig-0.10.1.tar.gz
cd pig-0.10.1
ant
```

Now you can run 'bin/pig'!

## Edit and run sent_counts.pig ##

Open 'ch3/pig/sent_counts.pig' and edit the path to match where you stored your emails as Avros:

```
/* Load the emails in avro format (edit the path to match where you saved them) using the AvroStorage UDF from Piggybank */
messages = LOAD '/tmp/my_inbox_directory' USING AvroStorage();
```
Now run 'pig -l /tmp -x local -v -w' and paste the code from this script, line-by-line into grunt. Try the 'DESCRIBE' command on the data at each step. When the script is finished running, check '/tmp/sent_counts.txt'

It will resemble this:

```
jira@apache.org pig-dev@hadoop.apache.org       22994
stack@duboce.net        user@hbase.apache.org   1933
jdcryans@apache.org     user@hbase.apache.org   1410
jira@apache.org russell.jurney@gmail.com        870
harsh@cloudera.com      common-user@hadoop.apache.org   685
dvryaboy@gmail.com      user@pig.apache.org     684
yuzhihong@gmail.com     user@hbase.apache.org   593
stack@duboce.net        hbase-user@hadoop.apache.org    581
michael_segel@hotmail.com       user@hbase.apache.org   435
doug.meil@explorysmedical.com   user@hbase.apache.org   404
jdcryans@apache.org     hbase-user@hadoop.apache.org    387
...
```

## Install MongoDB ##

Information on installing MongoDB on your platform are available at http://docs.mongodb.org/manual/installation/ and you can download MongoDB here: http://www.mongodb.org/downloads Be sure to download the 64-bit version of MongoDB.

For example, for Mac OS X:
```
wget http://fastdl.mongodb.org/osx/mongodb-osx-x86_64-2.2.2.tgz
tar -xvzf mongodb-osx-x86_64-2.2.2.tgz
cd mongodb-osx-x86_64-2.2.2
sudo mkdir -p /data/db/
sudo chown `id -u` /data/db
```

Now you must run MongoDB:

```
bin/mongod 2>&1 &
```

To connect to MongoDB:

```
bin/mongo agile_data
```

## Install MongoDB's Java Driver ##

The MongoDB Java driver is available at https://github.com/mongodb/mongo-java-driver/downloads Download it, and place it at the base of your MongoDB install directory.

```
cd <my_mongodb_install_path>
wget https://github.com/downloads/mongodb/mongo-java-driver/mongo-2.10.1.jar
```

## Install mongo-hadoop ##

The 'mongo-hadoop' project connects MongoDB and Hadoop. We'll be using it to connect MongoDB and Pig. To get it, you must use git:

```
git clone https://github.com/mongodb/mongo-hadoop.git
cd mongo-hadoop
./sbt update
./sbt package
find .|grep jar

./.lib/0.12.0-RC1/sbt-launch.jar
./core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
./examples/pigtutorial/lib/pigtutorial.jar
./flume/target/mongo-flume-1.1.0-SNAPSHOT.jar
./pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar
./target/mongo-hadoop-1.1.0-SNAPSHOT.jar
```

## Push data from Pig to MongoDB ##

Fix the paths in 'ch3/pig/mongo.pig' to point at your install paths and run it, to store the email sent counts to MongoDB.

```
REGISTER </my_mongo_install_path>/mongo-2.10.1.jar
REGISTER </my_mongo_install_path>/core/target/mongo-hadoop-core-1.1.0-SNAPSHOT.jar
REGISTER </my_mongo_install_path>/pig/target/mongo-hadoop-pig-1.1.0-SNAPSHOT.jar

set mapred.map.tasks.speculative.execution false
set mapred.reduce.tasks.speculative.execution false

sent_counts = LOAD '/tmp/sent_counts.txt' AS (from:chararray, to:chararray, total:long);
STORE sent_counts INTO 'mongodb://localhost/agile_data.sent_counts' USING com.mongodb.hadoop.pig.MongoStorage();
```

## Connect to MongoDB from Python ##

To install all python dependencies, execute:

```
pip install -r requirements.txt
```

Run 'ch3/python/mongo.py'

```
import pymongo
import json

conn = pymongo.Connection() ## defaults to localhost
db = conn.agile_data
results = db['sent_counts'].find()
for i in range(0, results.count()): ## Loop and print all results
  print results[i]
```

```
python ch3/python/mongo.py

{u'total': 22994L, u'to': u'pig-dev@hadoop.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f0710'), u'from': u'jira@apache.org'}
{u'total': 1933L, u'to': u'user@hbase.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f0714'), u'from': u'stack@duboce.net'}
{u'total': 1410L, u'to': u'user@hbase.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f0721'), u'from': u'jdcryans@apache.org'}
{u'total': 870L, u'to': u'russell.jurney@gmail.com', u'_id': ObjectId('50ea5e0a30040697fb0f0725'), u'from': u'jira@apache.org'}
{u'total': 685L, u'to': u'common-user@hadoop.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f0731'), u'from': u'harsh@cloudera.com'}
{u'total': 684L, u'to': u'user@pig.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f0732'), u'from': u'dvryaboy@gmail.com'}
{u'total': 593L, u'to': u'user@hbase.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f073c'), u'from': u'yuzhihong@gmail.com'}
{u'total': 581L, u'to': u'hbase-user@hadoop.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f073d'), u'from': u'stack@duboce.net'}
{u'total': 435L, u'to': u'user@hbase.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f0751'), u'from': u'michael_segel@hotmail.com'}
{u'total': 404L, u'to': u'user@hbase.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f0755'), u'from': u'doug.meil@explorysmedical.com'}
{u'total': 387L, u'to': u'hbase-user@hadoop.apache.org', u'_id': ObjectId('50ea5e0a30040697fb0f075a'), u'from': u'jdcryans@apache.org'}
...
```

## Install ElasticSearch ##

ElasticSearch is an easy to use search engine built on top of Lucene.

```
wget http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.2.tar.gz
tar -xvzf elasticsearch-0.20.2.tar.gz
cd elasticsearch-0.20.2
mkdir plugins
bin/elasticsearch -f
```

## Install Wonderdog ##

Wonderdog connects Pig to ElasticSearch

```
git clone https://github.com/infochimps-labs/wonderdog.git
cd wonderdog
mvn install
find .|grep jar

./target/wonderdog-1.0-SNAPSHOT.jar
```

## Push sent_counts from Pig to ElasticSearch ##

You'll need to replace the paths in the script at 'ch3/pig/elasticsearch.pig' to match your local 'elasticsearch' and 'wonderdog' install paths. Pay particular attention to the parameters given to 'com.infochimps.elasticsearch.pig.ElasticSearchStorage()', which is the path to 'elasticsearch.yml' (ElasticSearch's config file), and the path to ElasticSearch's 'plugins' directory. You must manually specify both.

Note: do NOT use an underscore '_' in an elasticsearch index name. It will fail badly and you won't know why.

```
/* Elasticsearch's own jars */
REGISTER /me/Software/elasticsearch-0.20.2/lib/*.jar

/* Register wonderdog - elasticsearch integration */
REGISTER /me/Software/wonderdog/target/wonderdog-1.0-SNAPSHOT.jar

...

/* Now load the JSON as a single chararray field, and index it into ElasticSearch with Wonderdog from InfoChimps */
email_json = LOAD '/tmp/inbox_json' AS (record:chararray);
STORE email_json INTO 'es://inbox/sentcounts?json=true&size=1000' USING com.infochimps.elasticsearch.pig.ElasticSearchStorage(
  '/me/Software/elasticsearch-0.20.2/config/elasticsearch.yml', 
  '/me/Software/elasticsearch-0.20.2/plugins');
```

To run it: 'pig -l /tmp -x local -v -w ch3/pig/elasticsearch.pig '

## Connect to ElasticSearch from Python with PyElasticsearch ##

We use 'pyelasticsearch' to connect to ElasticSearch from Python. To install all python dependencies, execute:

```
pip install -r requirements.txt
```

Now run 'ch3/python/elasticsearch.py':

```
import pyelasticsearch
elastic = pyelasticsearch.ElasticSearch('http://localhost:9200/inbox')
results = elastic.search("from:hadoop", index="sentcounts")
print results
```

```
python ch3/python/elasticsearch.py

{
    u'hits': {
        u'hits': [
            {
                u'_score': 1.0774149,
                u'_type': u'sentcounts',
                u'_id': u'FFGklMbtTdehUxwezlLS-g',
                u'_source': {
                    u'to': u'hadoop-studio-users@lists.sourceforge.net',
                    u'total': 196,
                    u'from': u'hadoop-studio-users-request@lists.sourceforge.net'
                },
                u'_index': u'inbox'
            },
            {
                u'_score': 1.0725133,
                u'_type': u'sentcounts',
                u'_id': u'rjxnV1zST62XoP6IQV25SA',
                u'_source': {
                    u'to': u'user@hadoop.apache.org',
                    u'total': 2,
                    u'from': u'hadoop@gmx.com'
                },
            ...
```

## Echo Service in Flask

Run 'ch3/python/flask_echo.py' to activate an echo service.

```
from flask import Flask
app = Flask(__name__)

@app.route("/<input>")
def hello(input):
  return input

if __name__ == "__main__":
  app.run(debug=True)
```

An echo service is quite simple:

```
curl 'http://localhost:5000/Hello%20World'
Hello World
```

## Display sent_counts in Flask ##

Run 'ch3/python/flask_mongo.py' to activate flask with MongoDB.

```
# Setup Mongo
conn = pymongo.Connection() ## defaults to localhost
db = conn.agile_data
sent_counts = db['sent_counts']

# Fetch from/to totals, given a pair of email addresses
@app.route("/sent_counts/<from_address>/<to_address>")
def sent_count(from_address, to_address):
  sent_count = sent_counts.find_one( {'from': from_address, 'to': to_address} )
  return json.dumps( {'from': sent_count['from'], 'to': sent_count['to'], 'total': sent_count['total']} )
```

Fetch the json output like so (modify to fit your inbox):

```
curl http://localhost:5000/sent_counts/russell.jurney@gmail.com/****.jurney@gmail.com
{"to": "****.jurney@gmail.com", "total": 552, "from": "russell.jurney@gmail.com"}```

## Conclusion ##

Thats it - localhost setup is done!
