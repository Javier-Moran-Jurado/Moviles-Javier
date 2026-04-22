class Airport {
  final int id;
  final String name;
  final String description;
  final String? city;
  final String? department;
  final String? image;
  final double? latitude;
  final double? longitude;

  Airport({
    required this.id,
    required this.name,
    required this.description,
    this.city,
    this.department,
    this.image,
    this.latitude,
    this.longitude,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'],
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      city: json['city'],
      department: json['department'],
      image: json['image'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}