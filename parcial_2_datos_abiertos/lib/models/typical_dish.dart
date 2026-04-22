class TypicalDish {
  final int id;
  final String name;
  final String description;
  final String? image;
  final String? department; // Asumiendo que puede tener relación con un departamento

  TypicalDish({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.department,
  });

  factory TypicalDish.fromJson(Map<String, dynamic> json) {
    return TypicalDish(
      id: json['id'],
      name: json['name'] ?? 'Sin nombre',
      description: json['description'] ?? 'Sin descripción',
      image: json['image'],
      department: json['department'],
    );
  }
}