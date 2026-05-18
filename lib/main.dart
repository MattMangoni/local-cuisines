import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/cuisines/presentation/home_screen.dart';

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
      home: const HomeScreen(),
    );
  }
}
