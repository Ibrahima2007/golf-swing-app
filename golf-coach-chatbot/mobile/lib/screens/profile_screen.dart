import 'package:flutter/material.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/information_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String username = "DemoUser"; // Replace with actual username later

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            // Title at the top, centered
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "$username Profile",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Centered content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Logo
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.person, color: Colors.white, size: 50),
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
                        // TODO: Show information dialog or page
                        Navigator.push(context,
                            MaterialPageRoute<void>(builder: (context) => const InformationPage()));
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
                        // TODO: Navigate to change password page
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
        color: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (context) => const HomePage()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              onPressed: () {
                // TODO: Navigate to chat screen
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white), // active screen
              onPressed: () {
                // Already on profile screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
