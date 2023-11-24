import 'package:flutter/material.dart';
import 'package:phale_mood/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.blue),
      ),
      home: const Home(),
    );
  }
}
