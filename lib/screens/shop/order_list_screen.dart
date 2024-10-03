import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/address.dart';
import 'package:project/models/shop_order.dart';
import 'package:project/screens/auth/address_book_form_screen.dart';
import 'package:project/screens/shop/order_detail_screen.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final AppController appController = Get.put(AppController());
  List<ShopOrderDTO> orders = [];
  List<Address> addressBooks = [];
  bool isLoading = false;
  Address? _selectedAddress;
  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchAddressBooks();
  }

  // Lấy danh sách đơn hàng từ API
  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true;
    });
    int accountId = appController.account.id;

    final String apiUrl = '/api/shop-orders/account/$accountId';

    try {
      var response = await RestService.get(apiUrl);
      //print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];
        if (data.isNotEmpty) {
          setState(() {
            orders = List<ShopOrderDTO>.from(data.map((item) => ShopOrderDTO.fromJson(item)));
            //xếp lại id theo thứ tự giảm dần
            orders.sort((a, b) => b.id.compareTo(a.id));
            appController.setTotalOrders(orders.length);
          });
        }
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body)['message'];

        Utils.noti(jsonResponse);
      } else {
        Utils.noti("Failed to load orders: ${response.statusCode}");
      }
    } catch (e) {
      Utils.noti('Error loading orders: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
          addressBooks = List<Address>.from(data.map((item) => Address.fromJson(item)));
          isLoading = false;
        });
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body)['message'];

        Utils.noti(jsonResponse);
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

  // Hàm hủy đơn hàng
  Future<void> _cancelOrder(int orderId, int index) async {
    final String apiUrl = '/api/shop-orders/$orderId/cancel';
    try {
      var response = await RestService.put(apiUrl, {});
      if (response.statusCode == 200) {
        Utils.noti("Order canceled successfully!");
        await _fetchOrders(); // Tải lại danh sách đơn hàng sau khi hủy
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body)['message'];

        Utils.noti(jsonResponse);
      } else {
        Utils.noti("Failed to cancel order: ${response.statusCode}");
      }
    } catch (e) {
      Utils.noti('Error canceling order: $e');
    }
  }

  //hàm update địa chỉ giao hàng
  Future<void> _updateDeliveryAddress(int orderId, Address address) async {
    final String apiUrl = '/api/shop-orders/$orderId/delivery-address';
    try {
      var response = await RestService.put(apiUrl, address.toJson());
      if (response.statusCode == 200) {
        await _fetchOrders(); // Tải lại danh sách đơn hàng sau khi cập nhật
        Utils.noti("Address updated successfully!");
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body)['message'];

        Utils.noti(jsonResponse);
      } else {
        Utils.noti("Failed to update address: ${response.statusCode}");
      }
    } catch (e) {
      Utils.noti('Error updating address: $e');
    }
  }

  Future<void> _editDeliveryAddress(int orderId, int index) async {
  String? selectedAddressId = orders[index].receiverAddressId.toString();
  Address? selectedAddress;

  if (selectedAddressId == '0' || selectedAddressId == 'null') {
    selectedAddressId = addressBooks.first.id.toString();
  }

  selectedAddress = addressBooks.firstWhere((element) => element.id == int.parse(selectedAddressId!));

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(
                  height: 150, // Giới hạn chiều cao cho Dropdown
                  child: SingleChildScrollView(
                    child: DropdownButtonFormField<String>(
                      value: selectedAddressId,
                      items: addressBooks.map<DropdownMenuItem<String>>((address) {
                        return DropdownMenuItem<String>(
                          value: address.id.toString(),
                          child: Text(
                            '${address.street}, ${address.city}, ${address.country}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAddressId = value;
                          selectedAddress = addressBooks.firstWhere((element) => element.id == int.parse(value!));
                          print('Selected Address updated: $selectedAddress');
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Utils.navigateTo(context, const AddressBookFormScreen());
                    if (result == 'success' || result == 'update') {
                      await _fetchAddressBooks(); // Tải lại danh sách địa chỉ sau khi thêm mới
                      if (isLoading == false) {
                        const Center(child: CircularProgressIndicator());
                      }
                      _editDeliveryAddress(orderId, index);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Address'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedAddress != null) {
                        print('Selected Address for Update: $selectedAddressId | $selectedAddress');
                        _updateDeliveryAddress(orderId, selectedAddress!); // Đảm bảo rằng _selectedAddress được cập nhật đúng
                        Navigator.pop(context); // Đóng BottomSheet
                      } else {
                        Utils.noti("Please select an address before updating.");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MaterialColors.socialFacebook,
                    ),
                    child: const Text('Update Address', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng BottomSheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MaterialColors.error,
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Your Orders',
        backButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: orders.isEmpty
                  ? const Center(
                      child: Text('No orders found.'),
                    )
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];

                        return GestureDetector(
                          onTap: () {
                            // Điều hướng sang trang chi tiết đơn hàng
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => OrderDetailScreen(orderId: order.id),
                            //   ),
                            // );
                            Utils.navigateTo(context, OrderDetailScreen(orderId: order.id));
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${order.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Total Price: \$${order.totalPrice}'),
                                  Text('Status: ${order.status}'),
                                  const SizedBox(height: 8),
                                  Text('Payment Type: ${order.paymentType}'),
                                  const SizedBox(height: 8),
                                  Text('Delivery Address: ${order.deliveryAddress}'),
                                  const SizedBox(height: 16),
                                  // Nút sửa địa chỉ giao hàng nếu trạng thái đơn hàng là 'Pending'
                                  order.status == 'Pending'
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _editDeliveryAddress(order.id, index);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: MaterialColors.socialFacebook,
                                              ),
                                              child: const Text('Edit Delivery Address', style: TextStyle(color: Colors.white)),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Utils.confirmDialog(
                                                  context,
                                                  'Cancel Order',
                                                  'Are you sure you want to cancel this order?',
                                                  () {
                                                    _cancelOrder(order.id, index);
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: MaterialColors.error,
                                              ),
                                              child: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
