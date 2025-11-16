import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final alignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        isUser ? Colors.green.shade600 : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: SelectableText(
          message.text,
          style: TextStyle(color: textColor, fontSize: 15),
        ),
      ),
    );
  }
}

