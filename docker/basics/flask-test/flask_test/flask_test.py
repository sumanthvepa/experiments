"""
  explore_flask.py: A simple flask application that returns a
  json string
"""
from flask import Flask, jsonify, Response

app = Flask(__name__)

@app.route('/')
def flask_test() -> Response:
  """
    Return a JSON dictionary indicating that the python app works
    :returns
  """
  message = {'flask_test': 'works'}
  return jsonify(message)
