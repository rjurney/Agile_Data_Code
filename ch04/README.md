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

## Setup the s3cmd to connect to Amazon Simple Storage Service (S3) ##

Firstly, sign up for a free account in Amazon Web Services. Credit card information is required in order to validate the account. As of writing, shouldn't worry about the charges as its very minimal if the size utilization is very small. (US$0.50 per month)

After obtaining your free account, enable usage of S3, create a user id, create a new group called admin, assigned admin access rights to the group, and finally assign the newly created user to the admin group. You'll then need to create an access key and secret key before you can configure the s3cmd (Amazon S3 web interface -> Security and Credentials). You'll need to download s3cmd utility (google and you shall find) and install it with the following (NOTE: I'm using my preference of /usr/local/ to hold all this executables. Feel free to change to where you normally put yours)
```
tar -zxvf s3cmd-1.5.0-beta1.tar.gz
mv s3cmd-1.5.0-beta1.tar.gz /usr/local/
mv /usr/local/s3cmd-1.5.0-beta1.tar.gz /usr/local/s3cmd
cd s3cmd
python setup.py install
```

Proceed to do configuration of s3cmd
```
[bash]$ ./s3cmd --configure
New settings:
  Access Key: <your access key>
  Secret Key: <your secret key>
  Encryption password: 
  Path to GPG program: None
  Use HTTPS protocol: True
  HTTP Proxy server name: 
  HTTP Proxy server port: 0
```

Upload the emails created so far into S3, by first creating a bucket (The bucket should be named according to where you've created it, as well as where you've stored your downloaded mail data per Chapter 03)
```
[bash]$ ./s3cmd mb s3://rjurney.email.upload
Bucket 's3://rjurney.email.upload/' created

[bash]$ ./s3cmd put --recursive /me/tmp/inbox s3://rjurney.email.upload
/tmp/gmail_data/part-1.avro -> s3://joechong.email.upload/part-1.avro  [1 of 1]
 3473302 of 3473302   100% in    7s   439.21 kB/s  done 
```

## Configure Amazon Elastic MapReduce ##

The sign-up process is trickier, as you'll need to subscribe to this offering under Amazon Web Services. Steps to be continued...........


## Conclusion ##

Thats it - cloud setup is done!
