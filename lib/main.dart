import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';

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
      theme: buildAppTheme(),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Cucine in città'),
          ),
        ),
      ),
    );
  }
}
