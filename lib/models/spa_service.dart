class SpaService {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;

  SpaService({required this.id, required this.categoryId, required this.name, required this.description, required this.price});

  factory SpaService.fromMap(Map<String, dynamic> map) {
    return SpaService(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
    );
  }
}
