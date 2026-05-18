import '../../data/city_suggestion.dart';

sealed class SearchState {
  const SearchState();
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuggestions extends SearchState {
  const SearchSuggestions(this.items);
  final List<CitySuggestion> items;
}

class SearchEmpty extends SearchState {
  const SearchEmpty(this.term);
  final String term;
}

class SearchError extends SearchState {
  const SearchError(this.error);
  final Object error;
}
