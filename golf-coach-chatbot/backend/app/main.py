#https://blog.logrocket.com/integrating-flask-flutter-apps/

from flask import Flask, request, jsonify
from flask_cors import CORS
from services import firebase_service
from routes.chat_routes import chat_bp
import os

app = Flask(__name__)
CORS(app)
basedir = os.path.abspath(os.path.dirname(__file__))

# Register chatbot routes
app.register_blueprint(chat_bp)

@app.route('/account/part1', methods=['POST'])
def createAccountBasics():
    try:
        print('Received account creation request:', request.json)
        if not request.json:
            return jsonify({'status': 'error', 'message': 'No data provided'}), 400
        
        response = firebase_service.createAccountBasics(request.json)
        print('Account creation response:', response)
        print('Response status:', response.get('status'))
        print('Response session_token:', response.get('session_token', 'NOT FOUND'))
        
        status_code = 200 if response.get('status') == 'success' else 400
        return jsonify(response), status_code
    except Exception as e:
        print(f'Exception in createAccountBasics route: {str(e)}')
        import traceback
        traceback.print_exc()
        return jsonify({'status': 'error', 'message': f'Server error: {str(e)}'}), 500


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
    app.run(debug=True, host='0.0.0.0', port=5000)