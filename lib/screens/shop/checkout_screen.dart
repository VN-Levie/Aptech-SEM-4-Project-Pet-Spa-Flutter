import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/auth/address_book_form_screen.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AppController appController = Get.put(AppController());
  List<Map<String, dynamic>> addressBooks = [];
  String? selectedAddressId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAddressBooks();
  }

  // Lấy danh sách địa chỉ từ API
  Future<void> _fetchAddressBooks() async {
    setState(() {
      isLoading = true;
    });
    int accountId = appController.account.id;
    final String apiUrl = '/api/address-books/account/$accountId';
    
    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        setState(() {
          addressBooks = List<Map<String, dynamic>>.from(data);
          if (addressBooks.isNotEmpty) {
            selectedAddressId = addressBooks.first['id'].toString();
          }
          isLoading = false;
        });
      } else {
        Utils.noti("Failed to load address books: ${response.statusCode}");
      }
    } catch (e) {
      Utils.noti('Error loading address books: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Liệt kê sản phẩm và số lượng trong giỏ hàng
  Widget _buildCartItems() {
    return Obx(() {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: appController.listProduct.length,
        itemBuilder: (context, index) {
          final item = appController.listProduct[index];
          return ListTile(
            leading: Image.network(Utils.replaceLocalhost(item.product.imageUrl)),
            title: Text(item.product.name),
            subtitle: Text('Quantity: ${item.quantity}'),
            trailing: Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}'),
          );
        },
      );
    });
  }

  // Chọn phương thức thanh toán (hiện tại chỉ có COD)
  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        RadioListTile(
          title: const Text('Cash on Delivery (COD)'),
          value: 'COD',
          groupValue: 'COD',
          onChanged: (value) {
            // Hiện tại chỉ có COD nên không cần xử lý gì thêm
          },
        ),
      ],
    );
  }

  // Xử lý thanh toán
  Future<void> _handleCheckout() async {
    if (selectedAddressId == null) {
      Utils.noti('Please select an address');
      return;
    }

    if (appController.listProduct.isEmpty) {
      Utils.noti('Your cart is empty');
      return;
    }

    double totalPrice = appController.listProduct.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));

    var orderDetails = {
      'totalPrice': totalPrice.toString(),
      'status': 'Pending',
      'paymentType': 'COD',
      'paymentStatus': 'Unpaid',
      'deliveryAddress': selectedAddressId,
      'accountId': appController.account.id,
      'productQuantities': appController.listProduct.map((item) {
        return {
          'productId': item.product.id,
          'quantity': item.quantity
        };
      }).toList(),
      // 'productQuantities': appController.listProduct.map((item) {
      //   return {
      //     'productId': item.product.id,
      //     'quantity': item.quantity
      //   };
      // }).toList(),
    };
  print(orderDetails);
    // Gửi yêu cầu tạo đơn hàng lên server
    try {
      var response = await RestService.post('/api/shop-orders', orderDetails);
      print(response.statusCode);
      if (response.statusCode == 201) {
        Utils.noti('Order placed successfully!');
        // Xóa giỏ hàng sau khi đặt hàng thành công
        //appController.clearCart();
        // Điều hướng về trang xác nhận đơn hàng hoặc trang chủ
       // Navigator.pop(context);
      } else {
        Utils.noti('Failed to place order. Try again later.');
      }
    } catch (e) {
      Utils.noti('Error placing order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Checkout',
        backButton: true,
        rightOptions: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phần chọn địa chỉ
                    const Text('Select Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    DropdownButtonFormField<String>(
                      value: selectedAddressId,
                      items: addressBooks.map<DropdownMenuItem<String>>((address) {
                        return DropdownMenuItem<String>(
                          value: address['id'].toString(),
                          child: Text('${address['street']}, ${address['city']}, ${address['country']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAddressId = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {
                        Utils.navigateTo(context, const AddressBookFormScreen()).then((value) {
                          if (value == 'success') {
                            _fetchAddressBooks(); // Tải lại danh sách địa chỉ sau khi thêm mới
                          }
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Address'),
                    ),
                    const SizedBox(height: 20),

                    // Liệt kê sản phẩm trong giỏ hàng
                    const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _buildCartItems(),
                    const SizedBox(height: 20),

                    // Chọn phương thức thanh toán
                    _buildPaymentMethod(),
                    const SizedBox(height: 20),

                    // Nút thanh toán
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleCheckout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MaterialColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('PLACE ORDER', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
