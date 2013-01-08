Agile Data - Chapter 7: Collecting and Displaying Atomic Records
===============================================================

# Setup Python Virtual Environment #
--------------------------------

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
pip install -r requirements.txt
```

Store Emails in MongoDB
-----------------------

```
pig -l /tmp -x local -param avros=<my_inbox_download_path> -param mongourl=mongodb://localhost/agile_data.emails -v -w avro_to_mongo.pig
```
