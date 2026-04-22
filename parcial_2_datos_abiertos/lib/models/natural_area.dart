class NaturalArea {
  final int id;
  final String name;
  final String description;
  final String? image;
  final double? latitude;
  final double? longitude;

  NaturalArea({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.latitude,
    this.longitude,
  });

  factory NaturalArea.fromJson(Map<String, dynamic> json) {
    return NaturalArea(
      id: json['id'],
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      image: json['image'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}