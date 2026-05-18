import '../../data/cuisine.dart';

sealed class CuisinesState {
  const CuisinesState();
}

class CuisinesLoading extends CuisinesState {
  const CuisinesLoading();
}

class CuisinesLoaded extends CuisinesState {
  const CuisinesLoaded(this.items);
  final List<Cuisine> items;
}

class CuisinesEmpty extends CuisinesState {
  const CuisinesEmpty();
}

class CuisinesError extends CuisinesState {
  const CuisinesError();
}
