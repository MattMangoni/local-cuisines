import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: CucineInCittaApp()));
}

class CucineInCittaApp extends StatelessWidget {
  const CucineInCittaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cucine in città',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('Cucine in città')),
      ),
    );
  }
}
