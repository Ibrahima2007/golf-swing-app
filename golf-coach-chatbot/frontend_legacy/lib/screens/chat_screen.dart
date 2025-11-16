import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/preset_dropdown.dart';

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final api = ref.read(apiServiceProvider);
  return ChatController(api);
});

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.videoId,
    required this.initialAnalysis,
  });

  final String videoId;
  final String initialAnalysis;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatControllerProvider.notifier)
          .initialize(widget.videoId, widget.initialAnalysis);
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({String? presetText}) async {
    final text = presetText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (presetText != null) {
      _messageController.text = presetText;
    }

    _messageController.clear();

    try {
      await ref
          .read(chatControllerProvider.notifier)
          .sendMessage(message: text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat error: $e')),
      );
    }
  }

  void _handleNavTap(int index) {
    if (index == 0) {
      Navigator.of(context).pop();
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile coming soon!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    final botMessages =
        chatState.messages.where((m) => m.role == ChatRole.bot).toList();
    final latestBotMessage =
        botMessages.isNotEmpty ? botMessages.last : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Swing Coach Chat',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade300, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.sportscourt,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PresetDropdown(
                presets: const [
                  'Where can I improve?',
                  'What did I do right?',
                  'What did I do wrong?',
                  'Rate my swing.',
                  'How can I get better?',
                ],
                onSelect: (value) => _sendMessage(presetText: value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: !_initialized && chatState.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final message = chatState.messages[index];
                            return MessageBubble(message: message);
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if (latestBotMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    latestBotMessage.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              if (latestBotMessage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.hand_thumbsup),
                      color: Colors.green.shade600,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(CupertinoIcons.hand_thumbsdown),
                      color: Colors.red.shade400,
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Ask your question',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.green.shade600,
                    child: IconButton(
                      onPressed: chatState.isSending
                          ? null
                          : () => _sendMessage(),
                      icon: chatState.isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              CupertinoIcons.paperplane_fill,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 1,
        selectedItemColor: Colors.green.shade700,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_crop_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ChatState {
  const ChatState({
    required this.messages,
    required this.isSending,
    required this.videoId,
    required this.hasInitialized,
  });

  final List<ChatMessage> messages;
  final bool isSending;
  final String? videoId;
  final bool hasInitialized;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? videoId,
    bool? hasInitialized,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      videoId: videoId ?? this.videoId,
      hasInitialized: hasInitialized ?? this.hasInitialized,
    );
  }

  factory ChatState.initial() => const ChatState(
        messages: [],
        isSending: false,
        videoId: null,
        hasInitialized: false,
      );
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._apiService) : super(ChatState.initial());

  final ApiService _apiService;

  void initialize(String videoId, String initialAnalysis) {
    if (state.hasInitialized && state.videoId == videoId) return;

    final initialMessage = ChatMessage(
      role: ChatRole.bot,
      text: initialAnalysis.isEmpty
          ? 'I’m reviewing your swing now. Ask me anything!'
          : initialAnalysis,
    );

    state = state.copyWith(
      videoId: videoId,
      messages: [initialMessage],
      hasInitialized: true,
    );
  }

  Future<void> sendMessage({required String message}) async {
    final videoId = state.videoId;
    if (videoId == null) {
      throw Exception('Video not initialized.');
    }

    final updatedMessages = [
      ...state.messages,
      ChatMessage(role: ChatRole.user, text: message),
    ];
    state = state.copyWith(messages: updatedMessages, isSending: true);

    try {
      final reply = await _apiService.sendChatMessage(
        videoId: videoId,
        message: message,
      );

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(role: ChatRole.bot, text: reply),
        ],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false);
      rethrow;
    }
  }
}

