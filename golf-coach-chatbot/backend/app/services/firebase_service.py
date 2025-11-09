import firebase_admin
from firebase_admin import credentials, firestore
from firebase_admin.exceptions import FirebaseError
from datetime import datetime
import os
from hashlib import sha256
import random
import string

def initialize_firebase():
    try:
        # Check if already initialized
        if not firebase_admin._apps:
            basedir = os.path.abspath(os.path.dirname(__file__))
            print(basedir)
            cred = credentials.Certificate(basedir + '/private_key.json')
            firebase_admin.initialize_app(cred)
        
        db = firestore.client()
        print("Successfully connected to Firebase")
        return db
        
    except FileNotFoundError:
        print("Service account key file not found")
        return None
    except FirebaseError as e:
        print(f"Firebase error: {e}")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None

# Usage
db = initialize_firebase()

def generateSalt(length: int = 12) -> str:
    characters = string.ascii_letters + string.digits + string.punctuation
    salt = ''.join(random.choice(characters) for i in range(length))
    return salt

def createAccountBasics(data: dict) -> dict:
    if (len(data['first-name']) < 1 or len(data['last-name']) < 1 or
        len(data['email']) < 1 or len(data['password']) < 8):
        return {'status': 'error', 'message': 'Invalid input data'}
    
    matchingEmail = db.collection('user-info').where('email', '==', data['email']).get()
    if len(matchingEmail) > 0:
        return {'status': 'error', 'message': 'Email already exists'}
    
    salt = generateSalt()
    hashedPassword = sha256((data['password'] + salt).encode()).hexdigest()

    newAccount = db.collection('user-info').document()
    newAccount.set({
        'first-name': data['first-name'],
        'last-name': data['last-name'],
        'email': data['email'],
        'gender': '',
        'hashed-password': hashedPassword,
        'salt': salt,
        'level-of-golf': '',
        'privacy': '',
        'role': '',
        'country': '',
        'data-of-birth': datetime.now(),
        'date-created': datetime.now(),
        'session-token': ''
    })

    return {'status': 'success', 'message': 'Account created successfully'}

def getAccount(email: str, password: str) -> dict:
    matchingEmail = db.collection('user-info').where('email', '==', email).get()
    if len(matchingEmail) == 0:
        return {'status': 'error', 'message': 'Account not found'}
    
    userDoc = matchingEmail[0]
    userData = userDoc.to_dict()
    salt = userData['salt']
    hashedPassword = sha256((password + salt).encode()).hexdigest()

    if hashedPassword != userData['hashed-password']:
        return {'status': 'error', 'message': 'Incorrect password'}
    
    return {
        'status': 'success',
        'message': 'Login successful',
        'user-info': userData
    }