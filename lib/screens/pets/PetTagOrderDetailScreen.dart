import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/pets/PetTagOrderDTO.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class PetTagOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const PetTagOrderDetailScreen({super.key, required this.orderId});

  @override
  _PetTagOrderDetailScreenState createState() => _PetTagOrderDetailScreenState();
}

class _PetTagOrderDetailScreenState extends State<PetTagOrderDetailScreen> {
  PetTagOrderDTO? petTagOrder;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPetTagOrderDetails();
  }

  Future<void> _fetchPetTagOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    final String orderApiUrl = 'api/pet-tag-orders/${widget.orderId}';

    try {
      var response = await RestService.get(orderApiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          petTagOrder = PetTagOrderDTO.fromJson(jsonResponse['data']);
          isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'PetTag Order Details',
        backButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : petTagOrder == null
              ? const Center(child: Text('Failed to load order details.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${petTagOrder!.id}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Price: \$${petTagOrder!.totalPrice}'),
                      Text('Status: ${petTagOrder!.status}'),
                      Text('Payment Type: ${petTagOrder!.paymentType}'),
                      const SizedBox(height: 8),
                      Text('Delivery Address: ${petTagOrder!.deliveryAddress}'),
                      const SizedBox(height: 16),
                      Text('Receiver Name: ${petTagOrder!.receiverName}'),
                      Text('Receiver Phone: ${petTagOrder!.receiverPhone}'),
                      Text('Receiver Email: ${petTagOrder!.receiverEmail}'),
                      const SizedBox(height: 16),
                      const Text('Pet Tags:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: petTagOrder!.petTags.length,
                          itemBuilder: (context, index) {
                            final petTag = petTagOrder!.petTags[index];
                            return ListTile(
                              title: Text(petTag.name),
                              subtitle: Text('Quantity: ${petTag.quantity}'),
                              trailing: Image.network(petTag.iconUrl, width: 50),
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
