import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../data/city_suggestion.dart';
import '../data/cuisine.dart';
import 'controllers/cuisines_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/selected_city_controller.dart';
import 'state/cuisines_state.dart';
import 'widgets/cuisines_grid.dart';
import 'widgets/status_views.dart';

class CuisinesView extends ConsumerWidget {
  const CuisinesView({required this.city, super.key});

  final CitySuggestion city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (lat: city.latitude, lng: city.longitude);
    final state = ref.watch(cuisinesControllerProvider(args));
    final controller = ref.read(cuisinesControllerProvider(args).notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              _BackButton(
                onPressed: () {
                  ref.invalidate(searchControllerProvider);
                  ref.read(selectedCityProvider.notifier).clear();
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _CityHeader(city: city),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: switch (state) {
                  CuisinesLoading() => const LoadingView(),
                  CuisinesLoaded(:final items) => _LoadedBody(items: items),
                  CuisinesEmpty() => const EmptyView(
                      message: 'Nessuna cucina disponibile per questa città.',
                    ),
                  CuisinesError() => ErrorView(onRetry: controller.retry),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.accent,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _CityHeader extends StatelessWidget {
  const _CityHeader({required this.city});

  final CitySuggestion city;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.accent, width: 3),
            ),
          ),
          child: Text(city.mainText, style: theme.textTheme.displayLarge),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(city.secondaryText, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.items});

  final List<Cuisine> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = items.length;
    final label = n == 1 ? '$n cucina disponibile' : '$n cucine disponibili';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: CuisinesGrid(items: items)),
      ],
    );
  }
}
