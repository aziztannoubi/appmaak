import 'package:flutter/material.dart';

import 'features/home/screens/main_shell.dart';

class Ma3akApp extends StatelessWidget {
  const Ma3akApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ma3ak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const MainShell(initialIndex: 1),
    );
  }
}
