import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/account_handler.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final account = Provider.of<AccountHandler>(context, listen: false);
    final String username = account.userName ; // get user’s name

    // Placeholder for 3 latest conversations (will come from Firestore later)
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
                // 👋 Welcome Section
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 30),
                  child: Column(
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
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                // 💬 Conversation History Header
                Text(
                  "Conversation History",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 🗂️ Recent Conversations List
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
                          leading: const Icon(Icons.chat_bubble_outline,
                              color: Colors.green),
                          title: Text(
                            chat["title"]!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            "Last updated: ${chat["date"]}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          onTap: () {
                            // TODO: Navigate to chat detail page
                          },
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 20),

                // 📄 View All Button (optional)
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(250, 50),
                    ),
                    onPressed: () {
                      // TODO: Navigate to full conversation list page
                    },
                    child: const Text("View All Conversations"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
