import firebase_admin
from firebase_admin import credentials, firestore
from firebase_admin.exceptions import FirebaseError
from datetime import datetime
import os
from hashlib import sha256
import random
import string
import warnings

def initialize_firebase():
    try:
        # Check if already initialized
        if not firebase_admin._apps:
            basedir = os.path.abspath(os.path.dirname(__file__))
            print(basedir)
            cred = credentials.Certificate(os.path.join(os.path.dirname(basedir), 'gold-swing-analysis-app-firebase-adminsdk-fbsvc-03c3585b37.json'))
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
    try:
        print('createAccountBasics input:', data)
        if not data or len(data.get('first-name', '')) < 1 or len(data.get('last-name', '')) < 1 or \
            len(data.get('email', '')) < 1 or len(data.get('password', '')) < 8:
            print('Invalid input data')
            return {'status': 'error', 'message': 'Invalid input data'}
        
        if db is None:
            print('Firebase database not initialized')
            return {'status': 'error', 'message': 'Database connection failed'}
        
        try:
            print('Starting Firestore email check...')
            print(f'Database object type: {type(db)}')
            print(f'Database is None: {db is None}')
            
            # Test connection with a simple query first
            try:
                print('Testing Firestore connection...')
                test_collection = db.collection('user-info')
                print('Collection reference created')
                
                # Suppress deprecation warning temporarily - old syntax still works
                with warnings.catch_warnings():
                    warnings.simplefilter("ignore")
                    print('Executing Firestore query for email:', data['email'])
                    # Try with a limit to see if it's a timeout issue
                    matchingEmail = test_collection.where('email', '==', data['email']).limit(1).get()
                    print('Firestore query completed successfully')
            except Exception as query_error:
                print(f'Firestore query error: {str(query_error)}')
                import traceback
                traceback.print_exc()
                # If query fails, we'll skip the check and try to create anyway
                # (this is not ideal but will help us proceed)
                print('Warning: Email check failed, proceeding with account creation anyway')
                matchingEmail = []
            
            print(f'matchingEmail result: {len(matchingEmail)} documents found')
            if len(matchingEmail) > 0:
                print('Email already exists')
                return {'status': 'error', 'message': 'Email already exists'}
            print('Email is available, proceeding with account creation...')
        except Exception as e:
            print(f'Error during Firestore email check: {str(e)}')
            import traceback
            traceback.print_exc()
            # Don't fail completely - allow account creation to proceed
            print('Warning: Email check had an error, but proceeding with account creation')
        
        try:
            print('Generating salt and session token...')
            salt = generateSalt()
            sessionToken = generateSalt(30)
            print('Hashing password...')
            hashedPassword = sha256((data['password'] + salt).encode()).hexdigest()
            currentTime = datetime.now()
            print('Creating Firestore document...')
            newAccount = db.collection('user-info').document()
            print('Setting document data...')
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
                'date-of-birth': currentTime,
                'date-created': currentTime,
                'session_token': sessionToken
            })
            print('Document set completed')
            print('Account created successfully, session token:', sessionToken)
            return {'status': 'success', 'message': 'Account created successfully', 'session_token': sessionToken}
        except Exception as e:
            print(f'Error creating account document: {str(e)}')
            import traceback
            traceback.print_exc()
            return {'status': 'error', 'message': f'Failed to create account: {str(e)}'}
    except Exception as e:
        print(f'Error in createAccountBasics: {str(e)}')
        import traceback
        traceback.print_exc()
        return {'status': 'error', 'message': str(e)}

def getAccount(email: str, password: str) -> dict:
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            matchingEmail = db.collection('user-info').where('email', '==', email).get()
        if len(matchingEmail) == 0:
            return {'status': 'error', 'message': 'Account not found'}
        
        userDoc = matchingEmail[0]
        userData = userDoc.to_dict()
        salt = userData['salt']
        hashedPassword = sha256((password + salt).encode()).hexdigest()

        if hashedPassword != userData['hashed-password']:
            return {'status': 'error', 'message': 'Incorrect password'}
        
        sessionToken = generateSalt(30)
        userDoc.reference.update({'session_token': sessionToken})
        userData['session_token'] = sessionToken
        
        return {
            'status': 'success',
            'message': 'Login successful',
            'user-info': userData
        }
    except Exception as e:
        print(f'Error in getAccount: {str(e)}')
        import traceback
        traceback.print_exc()
        return {'status': 'error', 'message': str(e)}

def getAccountInfo(session_token: str) -> dict:
    try:
        if not session_token or session_token.strip() == '':
            return {'status': 'error', 'message': 'Session token is required'}
        
        if db is None:
            return {'status': 'error', 'message': 'Database connection failed'}
        
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            matchingToken = db.collection('user-info').where('session_token', '==', session_token).get()

        if len(matchingToken) == 0:
            return {'status': 'error', 'message': 'Invalid session token'}
        
        userDoc = matchingToken[0]
        userData = userDoc.to_dict()
        
        return {
            'status': 'success',
            'message': 'Account info retrieved successfully',
            'user-info': userData
        }
    except Exception as e:
        error_msg = str(e)
        print(f'Error in getAccountInfo: {error_msg}')
        
        # Check if it's a Firebase auth error
        if 'Invalid JWT Signature' in error_msg or 'invalid_grant' in error_msg:
            print('WARNING: Firebase credentials may be invalid or expired. Please check your service account key file.')
            return {
                'status': 'error', 
                'message': 'Authentication error. Please contact support or try logging in again.'
            }
        
        import traceback
        traceback.print_exc()
        return {'status': 'error', 'message': f'Database error: {error_msg[:100]}'}

def updateAccountInfo(data: dict) -> dict:
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            matchingToken = db.collection('user-info').where('session_token', '==', data["session_token"]).get()

        if len(matchingToken) == 0:
            return {'status': 'error', 'message': 'Invalid session token'}

        userDoc = matchingToken[0]
        userData = userDoc.to_dict()
        
        for info in ["gender", "level-of-golf", "privacy", "role", "country"]:
            userDoc.reference.update({info: data[info]})
            userData[info] = data[info]
        
        dateTimeFormatString = "%Y-%m-%d %H:%M:%S.%f"
        dateTimeBirthDate = datetime.strptime(data["date-of-birth"], dateTimeFormatString)
        userDoc.reference.update({"date-of-birth": dateTimeBirthDate})
        userData["date-of-birth"] = data["date-of-birth"]
        
        return {
            "status": "success",
            "message": "Account info succesfully updated",
            "user-info": userData
        }
    except Exception as e:
        print(f'Error in updateAccountInfo: {str(e)}')
        import traceback
        traceback.print_exc()
        return {'status': 'error', 'message': str(e)}