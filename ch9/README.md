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

## Calculate something... ##

To calculate something...
```
pig -l /tmp -x local -v -w .pig
```

This will create a mongodb store: 'mongodb://localhost/agile_data.'

## Check MongoDB for Something ##

```
mongo agile_data

```
