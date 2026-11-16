import 'package:flutter/material.dart';

import 'widgets/greeting_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Testing Assignment')),
        body: const Center(child: GreetingCard(userName: 'Alice')),
      ),
    );
  }
}
