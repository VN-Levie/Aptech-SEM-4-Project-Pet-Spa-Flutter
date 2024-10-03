class PetTagDTO {
  final int id;
  final String name;
  final String description;
  final String iconUrl;

  PetTagDTO({required this.id, required this.name, required this.description, required this.iconUrl});

  factory PetTagDTO.fromMap(Map<String, dynamic> map) {
    return PetTagDTO(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconUrl: map['iconUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
    };
  }

  String toJson() => '''
  {
    "id": $id,
    "name": "$name",
    "description": "$description",
    "iconUrl": "$iconUrl"
  }
  ''';

  factory PetTagDTO.fromJson(Map<String, dynamic> json) {
    return PetTagDTO(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
    );
  }
}
