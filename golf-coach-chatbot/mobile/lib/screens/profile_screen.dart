import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../services/account_handler.dart';
import 'home_page.dart';
import 'information_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AccountHandler>(context, listen: false)
          .getUserInfo(Globals.sessionToken),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                "Error loading profile",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        // Loaded successfully
        final account = snapshot.data as Map<String, dynamic>;
        final String username = account["first-name"] ?? "Player";

        return _buildProfile(context, username);
      },
    );
  }

  // ——————————————————————————————————————————————
  //   FULL UI (everything centered like you wanted)
  // ——————————————————————————————————————————————
  Widget _buildProfile(BuildContext context, String username) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,

      body: SafeArea(
        child: Column(
          children: [
            // Title centered at top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "$username Profile",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            // Center column content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 40),

                    // Information Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InformationPage(),
                          ),
                        );
                      },
                      child: const Text("Information"),
                    ),
                    const SizedBox(height: 20),

                    // Change Password Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 50),
                      ),
                      onPressed: () {
                        // TODO: Change password screen
                      },
                      child: const Text("Change Password"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        color: Colors.green.shade600,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Home icon (outline because NOT active)
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
            ),

            // Chat icon
            IconButton(
              icon:
                  const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {},
            ),

            // Profile icon (filled because ACTIVE)
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
