Agile Data - Chapter 3: Collecting and Displaying Records
=========================================================

Setup your Python Virtual Environment
-------------------------------------

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
pip install -r requirements.txt
```

Download your Gmail Inbox!
--------------------------

```
# From ch3

# Download your gmail inbox
cd gmail
./gmail.py -m automatic -u me@gmail.com -p 'my_password_' -s ./email.avro.schema -f '[Gmail]/All Mail' -o /tmp/my_inbox_directory 2>&1 &
```

# Download Apache Pig
wget http://www.trieuvan.com/apache/pig/pig-0.10.1/pig-0.10.1.tar.gz
tar -xvzf pig-0.10.1.tar.gz
cd pig-0.10.1
ant

# Edit and run sent_counts.pig

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
```

# Install MongoDB

Information on installing MongoDB on your platform are available at http://docs.mongodb.org/manual/installation/ and you can download MongoDB here: http://www.mongodb.org/downloads

