from flask import Flask, jsonify, request
from .calculator import add, subtract, multiply, divide

app = Flask(__name__)

@app.get('/health')
def health():
    return jsonify(status='healthy')

@app.get('/')
def home():
    return 'Session 16 calculator: CI and CD verified'

@app.post('/calculate')
def calculate():
    data = request.get_json(silent=True) or {}
    operations = {'add': add, 'subtract': subtract, 'multiply': multiply, 'divide': divide}
    try:
        operation = operations[data['operation']]
        result = operation(float(data['a']), float(data['b']))
    except (KeyError, TypeError, ValueError):
        return jsonify(error='Invalid operation or operands'), 400
    return jsonify(result=result)
