import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bestiebite_repository.dart';
import '../state/search_state.dart';

class SearchController extends Notifier<SearchState> {
  static const _debounceDuration = Duration(milliseconds: 300);
  static const _minLength = 2;

  Timer? _debounceTimer;
  int _requestId = 0;
  String _lastTerm = '';

  @override
  SearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const SearchIdle();
  }

  void onTermChanged(String term) {
    _debounceTimer?.cancel();
    final trimmed = term.trim();
    _lastTerm = trimmed;
    if (trimmed.length < _minLength) {
      state = const SearchIdle();
      return;
    }
    state = const SearchLoading();
    _debounceTimer = Timer(_debounceDuration, () => _fetch(trimmed));
  }

  void retry() {
    if (_lastTerm.length < _minLength) return;
    state = const SearchLoading();
    _fetch(_lastTerm);
  }

  Future<void> _fetch(String term) async {
    final id = ++_requestId;
    
    try {
      final repo = ref.read(bestiebiteRepositoryProvider);
      final items = await repo.autocomplete(term);
      if (id != _requestId) return;
      state = items.isEmpty ? SearchEmpty(term) : SearchSuggestions(items);
    } catch (error) {
      if (id != _requestId) return;
      state = SearchError(error);
    }
  }
}

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);
