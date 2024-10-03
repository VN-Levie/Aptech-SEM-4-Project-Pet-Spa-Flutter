//  "id": 5,
//     "street": "1931 Pham The Hien",
//     "city": "Ho Chi Minh",
//     "state": "Quan 8",
//     "postalCode": "700000",
//     "country": "Vietnam",
//     "accountId": 6,
//     "fullName": "Le Viet Hai Duong",
//     "phoneNumber": "0393067818",
//     "email": "okthd111@gmail.com"

//   }

class Address {
  int id;
  String street;
  String city;
  String state;
  String postalCode;
  String country;
  int accountId;
  String fullName;
  String phoneNumber;
  String email;

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.accountId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      accountId: json['accountId'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'accountId': accountId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'Address{id: $id, street: $street, city: $city, state: $state, postalCode: $postalCode, country: $country, accountId: $accountId, fullName: $fullName, phoneNumber: $phoneNumber, email: $email}';
  }
}