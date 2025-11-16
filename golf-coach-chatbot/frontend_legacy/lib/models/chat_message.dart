enum ChatRole { user, bot }

class ChatMessage {
  ChatMessage({
    required this.role,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final ChatRole role;
  final String text;
  final DateTime timestamp;
}

