import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/upload_video_screen.dart';

void main() {
  runApp(const ProviderScope(child: GolfHelperApp()));
}

class GolfHelperApp extends StatelessWidget {
  const GolfHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Golf Helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFC8E6C9),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Colors.black87,
              displayColor: Colors.black87,
            ),
      ),
      home: const UploadVideoScreen(),
    );
  }
}
