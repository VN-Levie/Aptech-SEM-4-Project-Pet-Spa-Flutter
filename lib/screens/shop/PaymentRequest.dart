

class PaymentRequest {
  int? id;
  String? orderId;
  String? paymentId;
  List<String>? quantitySeat;
  List<String>? quantityDoubleSeat;
  double? totalPrice;
  int? showtimeId;
  int? voucherId; 

  PaymentRequest({
    this.id,
    this.orderId,
    this.paymentId,
    this.quantitySeat,
    this.quantityDoubleSeat,
    this.totalPrice,
    this.showtimeId,
    this.voucherId,   
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'paymentId': paymentId,
      'quantitySeat': quantitySeat ?? [],
      'quantityDoubleSeat': quantityDoubleSeat ?? [],
      'totalPrice': totalPrice,
      'showtimeId': showtimeId,
      'voucherId': voucherId,      
    };
  }

  // Create from JSON
  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'],
      orderId: json['orderId'],
      paymentId: json['paymentId'],
      quantitySeat: (json['quantitySeat'] as List?)?.map((item) => item as String).toList() ?? [],
      quantityDoubleSeat: (json['quantityDoubleSeat'] as List?)?.map((item) => item as String).toList() ?? [],
      totalPrice: json['totalPrice'],
      showtimeId: json['showtimeId'],
      voucherId: json['voucherId'],  
    );
  }

}
