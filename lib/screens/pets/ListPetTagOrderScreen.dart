import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/pets/PetTagOrderDTO.dart';

import 'package:project/screens/pets/PetTagOrderDetailScreen.dart';

import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class ListPetTagOrderScreen extends StatefulWidget {
  const ListPetTagOrderScreen({super.key});

  @override
  _ListPetTagOrderScreenState createState() => _ListPetTagOrderScreenState();
}

class _ListPetTagOrderScreenState extends State<ListPetTagOrderScreen> {
  final AppController appController = Get.put(AppController());
  List<PetTagOrderDTO> petTagOrders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPetTagOrders();
  }

  Future<void> _fetchPetTagOrders() async {
    setState(() {
      isLoading = true;
    });
    int accountId = appController.account.id;
    final String apiUrl = '/api/pet-tag-orders/account/$accountId';

    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];
        print(data);
        setState(() {
          petTagOrders = List<PetTagOrderDTO>.from(data.map((item) => PetTagOrderDTO.fromJson(item)));
          isLoading = false;
        });
      } else {
        Utils.noti("Failed to load pet tag orders: ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      Utils.noti('Error loading pet tag orders: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Your PetTag Orders',
        backButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: petTagOrders.isEmpty
                  ? const Center(child: Text('No orders found.'))
                  : ListView.builder(
                      itemCount: petTagOrders.length,
                      itemBuilder: (context, index) {
                        final order = petTagOrders[index];
                        return GestureDetector(
                          onTap: () {
                            Utils.navigateTo(context, PetTagOrderDetailScreen(orderId: order.id));
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
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Total Price: \$${order.totalPrice}'),
                                  Text('Status: ${order.status}'),
                                  const SizedBox(height: 8),
                                  Text('Payment Type: ${order.paymentType}'),
                                  const SizedBox(height: 8),
                                  Text('Delivery Address: ${order.deliveryAddress}'),
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
