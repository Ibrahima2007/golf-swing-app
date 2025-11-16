golf-coach-chatbot/
│
├── backend/ # Unified backend (current code)
│ ├── app/
│ │ ├── **init**.py
│ │ ├── config.py # API keys, Firebase config
│ │ ├── routes/
│ │ │ ├── **init**.py
│ │ │ ├── auth_routes.py # Firebase JWT verification
│ │ │ └── chat_routes.py # ChatGPT integration
│ │ ├── services/
│ │ │ ├── chatbot_service.py
│ │ │ ├── firebase_service.py
│ │ │ └── user_service.py
│ │ ├── utils/
│ │ │ ├── error_handlers.py
│ │ │ └── validation.py
│ │ └── database.py
│ ├── requirements.txt
│ └── legacy/ # Archived backend variants
│ ├── backend_flask/
│ ├── gpt_wrapper/
│ └── gptwrapper/
│
├── frontend/ # Unified Flutter app
│ ├── lib/
│ │ ├── main.dart # App entry
│ │ ├── navigation/
│ │ ├── providers/
│ │ ├── screens/ # Login, Home, Profile, Upload, Chatbot
│ │ ├── services/ # API + auth handlers
│ │ ├── models/
│ │ ├── utils/
│ │ └── widgets/
│ ├── pubspec.yaml
│ ├── android/ ios/ web/ # Platform-specific shells
│ └── README.md
│
├── frontend_legacy/ # Previous teammate Flutter app (reference only)
├── uploads/ # User-uploaded swing videos
├── docker-compose.yml
└── README.md (this file)
