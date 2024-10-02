import 'dart:convert';

class Account {
  // {id: 6, createdAt: null, updatedAt: null, deleted: false, email: svpv.hotrogh@gmail.com, password: null, roles: null, name: Admin, addressBooks: null}
  final int id;
  late String name;
  late String email;
  late String roles;

  Account({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roles: json['roles'],
    );
  }
  factory Account.fromJsonString(String json) {
    try {
      Map<String, dynamic> map = jsonDecode(json);
      return Account(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        roles: map['roles'],
      );
    } catch (e) {
      print('fromJsonString error: $e');
      throw Exception('Failed to load account from json');
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roles': roles,
    };
  }
}
