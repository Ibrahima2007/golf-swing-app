# golf-swing-app
golf-coach-chatbot/
│
├── backend/                          # Flask backend
│   ├── app/
│   │   ├── __init__.py               # Initialize Flask app
│   │   ├── config.py                 # API keys, Firebase config
│   │   ├── routes/
│   │   │   ├── __init__.py
│   │   │   ├── auth_routes.py        # Firebase JWT verification
│   │   │   └── chat_routes.py        # ChatGPT integration
│   │   ├── services/
│   │   │   ├── chatbot_service.py    # ChatGPT call logic
│   │   │   ├── firebase_service.py   # Firestore and Auth utilities
│   │   │   └── user_service.py       # User-related operations
│   │   ├── utils/
│   │   │   ├── error_handlers.py
│   │   │   └── validation.py
│   │   └── database.py               # Optional if mixing Firestore + SQL
│   │
│   ├── run.py                        # Entry point
│   ├── requirements.txt
│   └── .env.example                  # For API keys
│
├── mobile/                           # Flutter frontend
│   ├── lib/
│   │   ├── main.dart                 # App entry
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── chat_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── services/
│   │   │   ├── api_service.dart      # Talks to Flask API
│   │   │   └── firebase_service.dart # Auth + Firestore access
│   │   ├── models/
│   │   │   ├── message.dart
│   │   │   └── user.dart
│   │   ├── widgets/
│   │   │   ├── chat_bubble.dart
│   │   │   └── message_input.dart
│   │   └── utils/
│   │       └── constants.dart
│   │
│   ├── pubspec.yaml
│   └── android/ ios/ web/            # Flutter native directories
│
├── .gitignore
├── README.md
└── docker-compose.yml                # optional containerized setup
