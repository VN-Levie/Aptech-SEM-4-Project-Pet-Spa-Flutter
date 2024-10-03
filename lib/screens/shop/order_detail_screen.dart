import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/models/order_product_dto.dart';
import 'package:project/models/shop_order.dart';

import 'package:project/core/rest_service.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  ShopOrderDTO? order;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    final String orderApiUrl = '/api/shop-orders/${widget.orderId}';

    try {
      var response = await RestService.get(orderApiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        ShopOrderDTO fetchedOrder = ShopOrderDTO.fromJson(data);

        // Lấy chi tiết sản phẩm cho từng sản phẩm trong đơn hàng
        for (var productQuantity in fetchedOrder.productQuantities) {
          var productDetails = await _fetchProductDetails(productQuantity.productId);
          productQuantity.productDetails = productDetails; // Lưu thông tin sản phẩm vào đối tượng ProductQuantityDTO
        }

        setState(() {
          order = fetchedOrder;
        });
      } else {
        Utils.noti('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      Utils.noti('Error loading order: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Product?> _fetchProductDetails(int productId) async {
    final String productApiUrl = '/api/products/$productId';
    try {
      var response = await RestService.get(productApiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];
        return Product.fromJson(data);
      } else {
        Utils.noti('Failed to load product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Utils.noti('Error loading product: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Order Details',
        backButton: true,
        rightOptions: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text('Failed to load order details.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${order!.id}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Price: \$${order!.totalPrice}'),
                      Text('Status: ${order!.status}'),
                      Text('Payment Type: ${order!.paymentType}'),
                      const SizedBox(height: 8),
                      Text('Delivery Address: ${order!.deliveryAddress}'),
                      const SizedBox(height: 16),
                      Text('Receiver Name: ${order!.receiverName}'),
                      Text('Receiver Phone: ${order!.receiverPhone}'),
                      Text('Receiver Email: ${order!.receiverEmail}'),
                      const SizedBox(height: 16),
                      const Text('Products:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: order!.productQuantities.length,
                          itemBuilder: (context, index) {
                            final productQuantity = order!.productQuantities[index];
                            final product = productQuantity.productDetails;

                            return ListTile(
                              title: Text(product != null ? product.name : 'Product ID: ${productQuantity.productId}'),
                              subtitle: Text('Quantity: ${productQuantity.quantity}'),
                              trailing: product != null ? Image.network(product.imageUrl, width: 50) : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
