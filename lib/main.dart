import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const FlowCastApp());
}

class FlowCastApp extends StatelessWidget {
  const FlowCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowCast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}