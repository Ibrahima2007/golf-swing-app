import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../services/account_handler.dart';
import 'profile_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var sessionToken = Globals.sessionToken;
    return FutureBuilder(
      future: Provider.of<AccountHandler>(context, listen: false)
          .getUserInfo(sessionToken),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Error loading user data",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        // Data loaded
        final account = snapshot.data as Map<String, dynamic>;
        final String username = account["first-name"] ?? "Player";

        return _buildHomePage(context, username);
      },
    );
  }

  // ——————————————————————————————————————————————————————————————
  //   🔥 YOUR FULL HOMEPAGE UI (unchanged, just extracted cleanly)
  // ——————————————————————————————————————————————————————————————
  Widget _buildHomePage(BuildContext context, String username) {
    final List<Map<String, String>> recentConversations = [
      {"title": "Improving my backswing", "date": "Nov 10, 2025"},
      {"title": "How to increase swing speed", "date": "Nov 8, 2025"},
      {"title": "AI feedback on short game", "date": "Nov 6, 2025"},
    ];

    var pagePadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ————————————————— Header
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Welcome text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome!",
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

                      // Logo
                      Image.asset('images/icon.png', height: 200),
                    ],
                  ),
                ),

                // ————————————————— Conversation Header
                Text(
                  "Conversation History",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // ————————————————— Conversations List
                if (recentConversations.isEmpty)
                  const Center(
                    child: Text(
                      "No conversations yet.",
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
                            chat["title"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Last updated: ${chat["date"]}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          onTap: () {},
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 25),

                // ————————————————— New Conversation Button
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
                    onPressed: () {},
                    child: const Text(
                      "New Conversation",
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

      // ————————————————— Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        color: Colors.green.shade600,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home icon (solid)
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 30),
                onPressed: () {},
              ),

              // Chat icon
              IconButton(
                icon:
                    const Icon(Icons.chat_outlined, color: Colors.white, size: 28),
                onPressed: () {},
              ),

              // Profile icon
              IconButton(
                icon: const Icon(Icons.person_outline,
                    color: Colors.white, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
