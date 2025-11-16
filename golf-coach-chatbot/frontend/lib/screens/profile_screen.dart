import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_routes.dart';
import '../providers/navigation_provider.dart';
import '../services/account_handler.dart';
import '../utils/constants.dart';
import 'information_screen.dart';
import 'login_screen.dart';

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
                        Navigator.pushNamed(context, AppRoutes.information);
                      },
                      child: const Text("Information"),
                    ),
                    const SizedBox(height: 20),

                    // Chat shortcut
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 50),
                      ),
                      onPressed: () => context
                          .read<NavigationProvider>()
                          .setIndex(NavigationTabs.chat),
                      child: const Text("Jump to Chat"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
