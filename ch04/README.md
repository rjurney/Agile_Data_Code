Agile Data the Book
===================

You can buy the book [here](http://shop.oreilly.com/product/0636920025054.do). You can read the book on [O'Reilly OFPS](http://ofps.oreilly.com/titles/9781449326265/) now. Work the chapter code examples as you go. Don't forget to initialize your python environment. Try linux (apt-get, yum) or OS X (brew, port) packages if any of the requirements don't install in your [virtualenv](http://www.virtualenv.org/en/latest/).

Agile Data - Chapter 4: To the Cloud!
=========================================================

## Setup your Python Virtual Environment ##

```
# From project root

# Setup python virtualenv
virtualenv -p `which python2.7` venv --distribute
source venv/bin/activate
pip install -r requirements.txt
```

## Load a Procfile App Locally with Honcho ##

To use a Procfile to load our 'echo service' locally with Flask, run:

```
honcho start
```

You'll see:

```
$ honcho start
11:05:15 web.1  | started with pid 18080
11:05:16 web.1  |  * Running on http://127.0.0.1:5000/
11:05:16 web.1  |  * Restarting with reloader
11:05:22 web.1  | 127.0.0.1 - - [04/Feb/2013 11:05:22] "GET /eagea HTTP/1.1" 200 -
11:05:24 web.1  | 127.0.0.1 - - [04/Feb/2013 11:05:24] "GET /favicon.ico HTTP/1.1" 200 -
```

## Conclusion ##

Thats it - cloud setup is done!