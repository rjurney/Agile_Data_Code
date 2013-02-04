from flask import Flask

# Setup Flask
app = Flask(__name__)

# Simple echo service
@app.route("/<string:input>")
def hello(input):
  return input

if __name__ == "__main__":
  app.run(debug=True)
