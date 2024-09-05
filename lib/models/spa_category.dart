class SpaCategory {
  final int id;
  final String name;
  final String description;

  SpaCategory({required this.id, required this.name, required this.description});

  factory SpaCategory.fromMap(Map<String, dynamic> map) {
    return SpaCategory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}
