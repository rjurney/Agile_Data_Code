Agile Data Code Examples
========================


Chapter 2: Data
===============


Chapter 3: Agile Tools
======================

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
./gmail.py -m automatic -u me@gmail.com -p 'my_password_' -s ./email.avro.schema -f '[Gmail]/All Mail' -o /tmp/test_mbox 2>&1 &
```

Chapter 7: Collecting and Displaying Records
============================================

Chapter 8: Charts
=================

Chapter 9: Reports
==================

Chapter 10: Predictions
=======================

Chapter 11: Actions
===================
