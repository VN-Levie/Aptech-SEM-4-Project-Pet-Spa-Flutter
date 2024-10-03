// ShopOrderDTO{
// id long
// accountId*	long
// totalPrice*	double
// status*	string
// paymentType*	string
// paymentStatus*	string
// deliveryAddress*	string
// deliveryDate*	string
// productQuantities*	[ProductQuantityDTO{
// productId*	integer($int64)
// quantity*	integer($int32)
// receiverName*	string
// receiverPhone*	string
// receiverEmail*	string
// receiverAddressId*	integer($int64)
// }
import 'product_quantities.dart';
class ShopOrderDTO {
  int id;
  int accountId;
  double totalPrice;
  String status;
  String paymentType;
  String paymentStatus;
  String deliveryAddress;
  String deliveryDate;
  List<ProductQuantityDTO> productQuantities;
  String receiverName;
  String receiverPhone;
  String receiverEmail;
  int receiverAddressId;

  ShopOrderDTO({
    required this.id,
    required this.accountId,
    required this.totalPrice,
    required this.status,
    required this.paymentType,
    required this.paymentStatus,
    required this.deliveryAddress,
    required this.deliveryDate,
    required this.productQuantities,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverEmail,
    required this.receiverAddressId,
  });

  factory ShopOrderDTO.fromJson(Map<String, dynamic> json) {
    // {"status":200,"message":"List of shop orders for account","data":[
    //{"id":22,"accountId":6,"totalPrice":100.00,"status":"Pending","paymentType":"COD","paymentStatus":"Unpaid","deliveryAddress":"1931 Pham The Hien, Ho Chi Minh, Vietnam","deliveryDate":null,"productQuantities":[{"productId":1,"quantity":1}],"receiverName":"Le Viet Hai Duong","receiverPhone":"0393067818","receiverEmail":"okthd111@gmail.com","receiverAddressId":5}]}
    return ShopOrderDTO(
      id: json['id'],
      accountId: json['accountId'],
      totalPrice: json['totalPrice'],
      status: json['status'],
      paymentType: json['paymentType'],
      paymentStatus: json['paymentStatus'],
      deliveryAddress: json['deliveryAddress'],
      deliveryDate: json['deliveryDate'] ?? '',
      productQuantities: (json['productQuantities'] as List).map((item) => ProductQuantityDTO.fromJson(item)).toList(),
      receiverName: json['receiverName'],
      receiverPhone: json['receiverPhone'],
      receiverEmail: json['receiverEmail'],
      receiverAddressId: json['receiverAddressId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'totalPrice': totalPrice,
      'status': status,
      'paymentType': paymentType,
      'paymentStatus': paymentStatus,
      'deliveryAddress': deliveryAddress,
      'deliveryDate': deliveryDate!,
      'productQuantities': productQuantities.map((item) => item.toJson()).toList(),
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'receiverEmail': receiverEmail,
      'receiverAddressId': receiverAddressId,
    };
  }
}