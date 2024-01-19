import 'package:flutter/material.dart';
import 'ListGradesPage.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Entry System',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const ListGradesPage(),
    );
  }
}












