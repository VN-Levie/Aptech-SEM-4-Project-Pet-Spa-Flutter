class ShopProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  List<String> imageUrls = [];

  ShopProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  }) {
    imageUrls.add(imageUrl);
  }

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
