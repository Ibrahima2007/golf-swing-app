#https://blog.logrocket.com/integrating-flask-flutter-apps/
from flask import Flask, request, jsonify
from services import firebase_service
import os


app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))

@app.route('/account/part1', methods=['POST'])
def createAccountBasics():
    response = firebase_service.createAccountBasics(request.json)

    return jsonify(response)


@app.route('/account', methods=['GET'])
def getAccount():
    email = request.args.get('email')
    password = request.args.get('password')

    result = firebase_service.getAccount(email, password)

    return jsonify(result)

@app.route('/account/info', methods=['GET'])
def getAccountInfo():
    session_token = request.args.get('session_token')

    result = firebase_service.getAccountInfo(session_token)

    return jsonify(result)

@app.route('/account/update', methods=['POST'])
def updateAccountInfo():
    response = firebase_service.updateAccountInfo(request.json)
    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True)