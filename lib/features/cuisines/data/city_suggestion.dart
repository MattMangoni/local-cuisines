class CitySuggestion {
  const CitySuggestion({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.mainText,
    required this.secondaryText,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String mainText;
  final String secondaryText;

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final formatting = json['structured_formatting'] as Map<String, dynamic>?;

    return CitySuggestion(
      id: json['id'] as int,
      name: name,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      mainText: formatting?['main_text'] as String? ?? name,
      secondaryText: formatting?['secondary_text'] as String? ?? '',
    );
  }
}
