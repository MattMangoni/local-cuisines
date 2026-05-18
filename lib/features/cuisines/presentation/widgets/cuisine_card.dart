import 'package:flutter/material.dart';

import '../../../../core/theme.dart';
import '../../data/cuisine.dart';

class CuisineCard extends StatelessWidget {
  const CuisineCard({required this.cuisine, super.key});

  final Cuisine cuisine;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SizedBox(
                width: 56,
                height: 56,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.illustration,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            cuisine.name,
            textAlign: TextAlign.center,
            maxLines: cuisine.name.contains(' ') ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
