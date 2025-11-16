import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatSessionProvider extends ChangeNotifier {
  ChatSessionProvider(this._apiService);

  final ApiService _apiService;

  UploadResponse? _activeUpload;
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  bool get hasSession => _activeUpload != null;
  bool get isSending => _isSending;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  ChatMessage? get latestBotMessage {
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == ChatRole.bot) {
        return _messages[i];
      }
    }
    return null;
  }

  void initializeSession(UploadResponse response) {
    _activeUpload = response;
    _messages
      ..clear()
      ..add(
        ChatMessage(
          role: ChatRole.bot,
          text: response.initialAnalysis.isEmpty
              ? 'I’m reviewing your swing now. Ask me anything!'
              : response.initialAnalysis,
        ),
      );
    _isSending = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (_activeUpload == null || trimmed.isEmpty) {
      return;
    }

    _messages.add(ChatMessage(role: ChatRole.user, text: trimmed));
    _isSending = true;
    notifyListeners();

    try {
      final reply = await _apiService.sendChatMessage(
        videoId: _activeUpload!.videoId,
        message: trimmed,
      );
      _messages.add(ChatMessage(role: ChatRole.bot, text: reply));
    } catch (e) {
      _messages.add(
        ChatMessage(
          role: ChatRole.bot,
          text: 'Chat error: $e',
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearSession() {
    _activeUpload = null;
    _messages.clear();
    _isSending = false;
    notifyListeners();
  }
}

