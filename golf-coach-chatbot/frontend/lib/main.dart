import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/app_routes.dart';
import 'navigation/root_shell.dart';
import 'providers/chat_session_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/information_screen.dart';
import 'screens/login_screen.dart';
import 'services/account_handler.dart';
import 'services/api_service.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => ChatSessionProvider(context.read<ApiService>()),
        ),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => AccountHandler()),
      ],
      child: const GolfCoachApp(),
    ),
  );
}

class GolfCoachApp extends StatelessWidget {
  const GolfCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golf Swing Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.signup,
      routes: {
        AppRoutes.signup: (_) => const AccountCreationPage(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.profileInfo: (_) => const AccountCreationPagePart1(),
        AppRoutes.root: (_) => const RootShell(),
        AppRoutes.information: (_) => const InformationPage(),
      },
    );
  }
}
