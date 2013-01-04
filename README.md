Agile Data Code Examples
========================



Chapter 2
=========


Chapter 3
=========

Setup your Python Virtual Environment
-------------------------------------

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
```

Download your Gmail Inbox!
--------------------------

```
# From ch3

# Download your gmail inbox
cd gmail
./gmail.py -m automatic -u me@gmail.com -p 'my_password_' -s ./email.avro.schema -f '[Gmail]/All Mail' -o /tmp/test_mbox 2>&1 &
```

Chapter 6
=========
