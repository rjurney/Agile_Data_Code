Agile Data Code Examples
========================

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

Chapter 2: Data
===============

An example spreadsheet is available at [ch02/Email Analysis.xlsb](https://github.com/rjurney/Agile_Data_Code/blob/master/ch02/Email%20Analysis.xlsb). Example Pig code is available at [ch02/probability.pig](https://github.com/rjurney/Agile_Data_Code/blob/master/ch02/probability.pig).

Chapter 3: Agile Tools
======================

Full tutorial in [Chapter 3 README](https://github.com/rjurney/Agile_Data_Code/tree/master/ch03).

Highlight:

Download your Gmail Inbox!
--------------------------

```
# From ch3

# Download your gmail inbox
cd gmail
./gmail.py -m automatic -u me@gmail.com -p 'my_password_' -s ./email.avro.schema -f '[Gmail]/All Mail' -o /tmp/test_mbox 2>&1 &
```

Chapter 7: Collecting and Displaying Atomic Records
===================================================

[Chapter 7](https://github.com/rjurney/Agile_Data_Code/tree/master/ch07) tutorial.

Chapter 8: Creating Charts
==========================

[Chapter 8](https://github.com/rjurney/Agile_Data_Code/tree/master/ch08) tutorial.

Chapter 9: Building Interactive Reports
=======================================

[Chapter 9](https://github.com/rjurney/Agile_Data_Code/tree/master/ch09) tutorial.

Chapter 10: Making Predictions
==============================

[Chapter 10](https://github.com/rjurney/Agile_Data_Code/tree/master/ch10) tutorial.

Chapter 11: Driving Actions
===========================

[Chapter 11](https://github.com/rjurney/Agile_Data_Code/tree/master/ch11) tutorial.
