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

## Signup for DotCloud ##

Visit (https://www.dotcloud.com/accounts/register/)[https://www.dotcloud.com/accounts/register/] and signup. Check out the docs: (http://docs.dotcloud.com/0.9/services/python/)[http://docs.dotcloud.com/0.9/services/python/] and this doc on deploying a Flask app via wsgi: (http://flask.pocoo.org/snippets/48/)[http://flask.pocoo.org/snippets/48/]

## Install the DotCloud CLI ##

```
sudo pip install dotcloud
```

## Setup the DotCloud CLI ##

```
dotcloud setup
```

## Setup ch04 to Deploy ##

cd ch04/
dotcloud create myapp
dotcloud push myapp

## Conclusion ##

Thats it - cloud setup is done!