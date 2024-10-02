class SpaService {
  final int id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  SpaService({required this.id, required this.categoryId, required this.name, required this.description, required this.price, required this.imageUrl});

  factory SpaService.fromMap(Map<String, dynamic> map) {
    return SpaService(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  String toJson() => '''
  {
    "id": $id,
    "category_id": $categoryId,
    "name": "$name",
    "description": "$description",
    "price": $price,
    "imageUrl": "$imageUrl"
  }
  ''';

  factory SpaService.fromJson(Map<String, dynamic> json) {
    try {
      return SpaService(
      id: json['id'],
      categoryId: json['category'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
    } catch (e) {
      //print("Error parsing SpaService: $e");
    }
    return SpaService(id: 0, categoryId: 0, name: "", description: "", price: 0, imageUrl: "");
  }
}
