import 'package:flutter/material.dart';
import 'package:gamification/gamification_list_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const GamificationListView(),
      theme: ThemeData(
        primaryColor: Colors.red,
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.red,
        ),
      ),
    );
  }
}
