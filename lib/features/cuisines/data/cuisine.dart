class Cuisine {
  const Cuisine({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String imageUrl;

  factory Cuisine.fromJson(Map<String, dynamic> json) {
    return Cuisine(
      id: json['id'] as int,
      name: (json['name_it'] as String?) ?? (json['name'] as String? ?? ''),
      imageUrl: json['image_emoji'] as String? ?? '',
    );
  }
}
