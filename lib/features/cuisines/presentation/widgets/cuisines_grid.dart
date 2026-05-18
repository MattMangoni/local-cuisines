import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../../data/cuisine.dart';
import 'cuisine_card.dart';

class CuisinesGrid extends StatelessWidget {
  const CuisinesGrid({required this.items, super.key});

  final List<Cuisine> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => CuisineCard(cuisine: items[i]),
    );
  }
}
