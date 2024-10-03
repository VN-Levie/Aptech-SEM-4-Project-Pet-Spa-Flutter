// productQuantities*	[ProductQuantityDTO{
// productId*	integer($int64)
// quantity*	integer($int32)

import 'package:project/models/order_product_dto.dart';

class ProductQuantityDTO {
  int productId;
  int quantity;
  Product? productDetails; // Thêm thuộc tính này để lưu thông tin chi tiết sản phẩm

  ProductQuantityDTO({
    required this.productId,
    required this.quantity,
    this.productDetails,
  });

  factory ProductQuantityDTO.fromJson(Map<String, dynamic> json) {
    return ProductQuantityDTO(
      productId: json['productId'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
