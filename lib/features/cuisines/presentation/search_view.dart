import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import 'controllers/search_controller.dart';
import 'state/search_state.dart';
import 'widgets/search_bar.dart';
import 'widgets/status_views.dart';
import 'widgets/suggestions_list.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Cucine in città',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              SearchPillField(
                controller: _textController,
                onChanged: controller.onTermChanged,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: switch (state) {
                  SearchIdle() => const IdleView(),
                  SearchLoading() => const LoadingView(),
                  SearchSuggestions(:final items) =>
                    SuggestionsList(items: items),
                  SearchEmpty(:final term) => EmptyView(
                      message: "Nessuna città trovata per '$term'",
                    ),
                  SearchError() => ErrorView(onRetry: controller.retry),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
