import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/city_suggestion.dart';

class SelectedCityController extends Notifier<CitySuggestion?> {
  @override
  CitySuggestion? build() => null;

  void select(CitySuggestion city) => state = city;
  void clear() => state = null;
}

final selectedCityProvider =
    NotifierProvider<SelectedCityController, CitySuggestion?>(
  SelectedCityController.new,
);
