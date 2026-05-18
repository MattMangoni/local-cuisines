import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/selected_city_controller.dart';
import 'cuisines_view.dart';
import 'search_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    
    return city == null ? const SearchView() : CuisinesView(city: city);
  }
}
