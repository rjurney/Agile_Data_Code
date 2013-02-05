from flask import Flask
import os

# Setup Flask
app = Flask(__name__)

# Simple echo service
@app.route("/<string:input>")
def hello(input):
  return input

if __name__ == "__main__":
  port = int(os.environ.get('PORT', 5000))
  app.run(host='0.0.0.0', port=port)
