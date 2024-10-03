import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/address.dart';
import 'package:project/screens/auth/address_book_form_screen.dart';
import 'package:project/screens/home.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class CheckoutPetTagScreen extends StatefulWidget {
  const CheckoutPetTagScreen({super.key, required this.petTagId});
  final int petTagId;

  @override
  _CheckoutPetTagScreenState createState() => _CheckoutPetTagScreenState();
}

class _CheckoutPetTagScreenState extends State<CheckoutPetTagScreen> {
  final AppController appController = Get.put(AppController());
  Map<String, dynamic>? petTag; // Để lưu thông tin PetTag từ API
  List<Address> addressBooks = [];
  String? selectedAddressId;
  bool isLoading = false;
  var textFront = TextEditingController();
  var textBack = TextEditingController();
  var num = TextEditingController();
  double total = 0.0;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    setState(() {
      textBack.text = 'Your custom text back';
      textFront.text = 'Your custom text front';
      num.text = '1';
      total = calculateTotal(); // Khởi tạo tổng tiền
    });
    _fetchPetDetails();
    _fetchAddressBooks(); // Gọi hàm để lấy danh sách địa chỉ
  }

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
          addressBooks = List<Address>.from(data.map((item) => Address.fromJson(item)));
          if (addressBooks.isNotEmpty) {
            selectedAddressId = addressBooks.first.id.toString();
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

  // Hàm tính tổng tiền
  double calculateTotal() {
    double total = 0.0;
    int qty = int.tryParse(num.text) ?? 1;
    if (qty < 0) qty = 0;
    total += petTag != null ? petTag!['price'] * qty : 0;
    return total;
  }

  // Hàm lấy thông tin pet tag từ API
  Future<void> _fetchPetDetails() async {
    setState(() {
      isLoading = true; // Bắt đầu loading
    });
    try {
      var response = await RestService.get('/api/pet-tags/${widget.petTagId}');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        setState(() {
          petTag = jsonResponse['data'];
          total = calculateTotal(); // Cập nhật lại tổng tiền sau khi có giá sản phẩm
          print(petTag);
        });
      } else {
        Utils.noti('Pet Tag not found!');
        Navigator.pop(context, 'update');
      }
    } catch (e) {
      Utils.noti('Failed to load Pet Tag details.');
      Navigator.pop(context, 'update');
    } finally {
      setState(() {
        isLoading = false; // Kết thúc loading
      });
    }
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
        Card(
          color: MaterialColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Delivery time will be updated after the system confirms the order.',
                  style: TextStyle(color: MaterialColors.caption),
                ),
              ],
            ),
          ),
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

    Address address = addressBooks.firstWhere((element) => element.id.toString() == selectedAddressId);
    String fullAddress = '${address.street}, ${address.city}, ${address.state}, ${address.country}, ${address.postalCode}';

    var orderDetails = {
      "accountId": appController.account.id,
      "petTagId": widget.petTagId,
      "textFront": textFront.text,
      "textBack": textBack.text,
      "num": int.parse(num.text),
      "fullAddress": fullAddress,
      "receiverName": address.fullName,
      "receiverPhone": address.phoneNumber,
      "receiverEmail": address.email,
      "receiverAddressId": address.id,
    };

    // Gửi yêu cầu tạo đơn hàng lên server
    try {
      var response = await RestService.post('/api/pet-tag-orders', orderDetails);
      if (response.statusCode == 201) {
        Utils.noti('Order placed successfully!');
        appController.clearCart();
        await Utils.navigateTo(context, const HomeScreen(), clearStack: true);
      } else {
        var jsonResponse = jsonDecode(response.body)['message'];
        Utils.noti(jsonResponse);
      }
    } catch (e) {
      Utils.noti('Something went wrong. Please try again later.');
    }
  }

  // Liệt kê sản phẩm và số lượng trong giỏ hàng
  Widget _buildCartItems() {
    return Column(
      children: [
        ListView.builder(
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
        ),
        const Divider(),
        ListTile(
          title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
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
                    // Hiển thị thông tin sản phẩm PetTag
                    if (petTag != null) ...[
                      Image.network(
                        Utils.replaceLocalhost(petTag!['iconUrl']),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        petTag!['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        petTag!['description'],
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Phần nhập liệu mặt trước và mặt sau
                    const Text('Front Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextFormField(
                      controller: textFront,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter custom text for the front',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Back Text', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextFormField(
                      controller: textBack,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter custom text for the back',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextFormField(
                      controller: num,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          int qty = int.tryParse(value) ?? 1;
                          if (qty < 0) {
                            num.text = '0';
                          }
                          total = calculateTotal(); // Cập nhật lại tổng tiền
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter quantity',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Liệt kê sản phẩm trong giỏ hàng
                    const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    _buildCartItems(),
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
