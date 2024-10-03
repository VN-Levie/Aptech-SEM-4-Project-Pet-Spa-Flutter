import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class HotelBookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const HotelBookingDetailScreen({super.key, required this.bookingId});

  @override
  _HotelBookingDetailScreenState createState() => _HotelBookingDetailScreenState();
}

class _HotelBookingDetailScreenState extends State<HotelBookingDetailScreen> {
  Map<String, dynamic>? booking;
  Map<String, dynamic>? petDetails;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    setState(() {
      isLoading = true;
    });

    final String bookingApiUrl = '/api/hotel-bookings/${widget.bookingId}';

    try {
      var response = await RestService.get(bookingApiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        var data = jsonResponse['data'];

        setState(() {
          booking = data;
        });

        // Fetch pet details
        await _fetchPetDetails();
      } else {
        Utils.noti('Failed to load booking details: ${response.statusCode}');
      }
    } catch (e) {
      Utils.noti('Error loading booking details: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _fetchPetDetails() async {
    if (booking == null) return;
    print(booking);
    // Fetch pet details
    final String petApiUrl = '/api/pets/${booking!['accountId']}/${booking!['petId']}';
    try {
      var petResponse = await RestService.get(petApiUrl);
      if (petResponse.statusCode == 200) {
        var petJson = jsonDecode(utf8.decode(petResponse.bodyBytes));
        setState(() {
          petDetails = petJson['data'];
        });
      }
    } catch (e) {
      Utils.noti('Error loading pet details: $e');
    }
  }

  Future<void> _cancelBooking() async {
    final String cancelApiUrl = '/api/hotel-bookings/cancel/${booking!['id']}';

    try {
      var response = await RestService.put(cancelApiUrl, {});
      if (response.statusCode == 200) {
        Utils.noti("Booking canceled successfully!");
       await _fetchBookingDetails();
      } else {
        Utils.noti("Failed to cancel booking: ${response.statusCode}");
      }
    } catch (e) {
      Utils.noti('Error canceling booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Hotel Booking Details',
        backButton: true,
        rightOptions: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : booking == null
              ? const Center(child: Text('Failed to load booking details.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailCard(
                          title: 'Booking Information',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Booking ID:', booking!['id'].toString()),
                              _buildDetailRow('Check-in Date:', DateFormat('yyyy-MM-dd').format(DateTime.parse(booking!['checkInDate']))),
                              _buildDetailRow('Check-out Date:', DateFormat('yyyy-MM-dd').format(DateTime.parse(booking!['checkOutDate']))),
                              _buildDetailRow('Total Price:', '\$${booking!['totalPrice']}'),
                              _buildDetailRow('Status:', booking!['status']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          title: 'Pet Information',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Pet:', petDetails?['name'] ?? 'N/A'),
                              _buildDetailRow('Pet Description:', petDetails?['description'] ?? 'N/A'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          title: 'Pickup & Return',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Pick-up Type:', booking!['pickUpType']),
                              _buildDetailRow('Pick-up Address:', booking!['pickUpAddress']),
                              _buildDetailRow('Return Type:', booking!['returnType']),
                              _buildDetailRow('Return Address:', booking!['returnAddress']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailCard(
                          title: 'Payment Details',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Payment Type:', booking!['paymentType']),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        booking!['status'] == 'Pending'
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Utils.confirmDialog(
                                      context,
                                      'Cancel Booking',
                                      'Are you sure you want to cancel this booking?',
                                      _cancelBooking,
                                      cancelText: 'Let me think again',
                                      confirmText: 'Yes, cancel it',
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MaterialColors.error,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  ),
                                  child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDetailCard({required String title, required Widget content}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
