import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    return 'http://10.0.2.2:5000';
  }

  static String get accountBaseUrl => '${apiBaseUrl}/account';
  static String get uploadEndpoint => '${apiBaseUrl}/upload_video';
  static String get chatEndpoint => '${apiBaseUrl}/chat';
}

class NavigationTabs {
  static const int home = 0;
  static const int upload = 1;
  static const int chat = 2;
  static const int profile = 3;
}

const List<String> defaultPresetQuestions = [
  'Where can I improve?',
  'What did I do right?',
  'What did I do wrong?',
  'Rate my swing.',
  'How can I get better?',
];

