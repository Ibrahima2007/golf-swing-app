import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import '../services/account_handler.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionToken = Globals.sessionToken;
    final isGuest = Globals.isGuest || sessionToken.isEmpty;

    if (isGuest) {
      return const _HomeContent(username: 'Guest');
    }

    return FutureBuilder(
      future: Provider.of<AccountHandler>(context, listen: false)
          .getUserInfo(sessionToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Error loading user data',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        final account = snapshot.data as Map<String, dynamic>;
        final String username = account['first-name'] ?? 'Player';
        return _HomeContent(username: username);
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> recentConversations = [
      {'title': 'Improving my backswing', 'date': 'Nov 10, 2025'},
      {'title': 'How to increase swing speed', 'date': 'Nov 8, 2025'},
      {'title': 'AI feedback on short game', 'date': 'Nov 6, 2025'},
    ];

    const pagePadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            username,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      Image.asset('images/icon.png', height: 120),
                    ],
                  ),
                ),
                Text(
                  'Conversation History',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (recentConversations.isEmpty)
                  const Center(
                    child: Text(
                      'No conversations yet.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )
                else
                  Column(
                    children: recentConversations.map((chat) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.green,
                          ),
                          title: Text(
                            chat['title']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            'Last updated: ${chat["date"]}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          onTap: () => context
                              .read<NavigationProvider>()
                              .setIndex(NavigationTabs.chat),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade400,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => context
                        .read<NavigationProvider>()
                        .setIndex(NavigationTabs.chat),
                    child: const Text(
                      'New Conversation',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

