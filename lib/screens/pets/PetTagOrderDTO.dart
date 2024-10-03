class PetTagOrderDTO {
  final int id;
  final double totalPrice;
  final String status;
  final String paymentType;
  final String deliveryAddress;
  final String receiverName;
  final String receiverPhone;
  final String receiverEmail;
  final List<PetTag> petTags;

  PetTagOrderDTO({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.paymentType,
    required this.deliveryAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverEmail,
    required this.petTags,
  });

  factory PetTagOrderDTO.fromJson(Map<String, dynamic> json) {
    return PetTagOrderDTO(
      id: json['id'],
      totalPrice: json['totalPrice'] ?? 0.0,
      status: json['status'] ?? '',
      paymentType: json['paymentType'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverEmail: json['receiverEmail'] ?? '',
      petTags: json['petTags'] != null
          ? List<PetTag>.from(json['petTags'].map((item) => PetTag.fromJson(item)))
          : [],
    );
  }
}

class PetTag {
  final String name;
  final String iconUrl;
  final int quantity;

  PetTag({
    required this.name,
    required this.iconUrl,
    required this.quantity,
  });

  factory PetTag.fromJson(Map<String, dynamic> json) {
    return PetTag(
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }
}
