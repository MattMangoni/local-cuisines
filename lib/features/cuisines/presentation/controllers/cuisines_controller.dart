import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/bestiebite_repository.dart';
import '../state/cuisines_state.dart';

typedef CuisinesArgs = ({double lat, double lng});

class CuisinesController extends Notifier<CuisinesState> {
  CuisinesController(this.args);

  final CuisinesArgs args;

  @override
  CuisinesState build() {
    _load();
    return const CuisinesLoading();
  }

  Future<void> retry() async {
    state = const CuisinesLoading();
    await _load();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(bestiebiteRepositoryProvider);
      final items = await repo.cuisinesByLocation(args.lat, args.lng);
      state = items.isEmpty ? const CuisinesEmpty() : CuisinesLoaded(items);
    } catch (error) {
      state = CuisinesError(error);
    }
  }
}

final cuisinesControllerProvider = NotifierProvider.family<CuisinesController,
    CuisinesState, CuisinesArgs>(CuisinesController.new);
