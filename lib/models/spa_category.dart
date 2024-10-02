class SpaCategory {
  final int id;
  final String name;
  final String description;
  final String imageUrl;

  SpaCategory({required this.id, required this.name, required this.description, required this.imageUrl});

  factory SpaCategory.fromMap(Map<String, dynamic> map) {
    return SpaCategory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  String toJson() => '''
  {
    "id": $id,
    "name": "$name",
    "description": "$description",
    "imageUrl": "$imageUrl"
  }
  ''';

  factory SpaCategory.fromJson(Map<String, dynamic> json) {
    return SpaCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}
