import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/spa_booking/spa_booking_detail_screen.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final AppController appController = Get.put(AppController());
  List<dynamic> bookings = [];
  List<dynamic> filteredBookings = [];
  bool isLoading = false;
  bool showAllBookings = true;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    isLoading = true;
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      isLoading = true;
    });

    int accountId = appController.account.id;
    final String apiUrl = '/api/spa/bookings/account/$accountId';

    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        var data = jsonResponse['data'];
        if (data.isNotEmpty) {
          setState(() {
            bookings = data;
            bookings.sort((a, b) => b['id'].compareTo(a['id']));
            _fetchProductAndPetDetails();
          });
        }
      } else {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        Utils.noti(jsonResponse['message']);
      }
    } catch (e) {
      Utils.noti('Error loading bookings: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(String booking) async {
    final String cancelApiUrl = '/api/spa/bookings/cancel/$booking';

    try {
      var response = await RestService.put(cancelApiUrl, {});
      if (response.statusCode == 200) {
        Utils.noti("Booking canceled successfully!");
        await _fetchBookings();
      } else {
        Utils.noti("Failed to cancel booking: ${response.statusCode}");
      }
    } catch (e) {
      Utils.noti('Error canceling booking: $e');
    }
  }

  Future<void> _fetchProductAndPetDetails() async {
    for (var booking in bookings) {
      var productResponse = await RestService.get('/api/spa/product/${booking['serviceId']}');
      if (productResponse.statusCode == 200) {
        var productJson = jsonDecode(utf8.decode(productResponse.bodyBytes));
        booking['productDetails'] = productJson['data'];
      }

      var petResponse = await RestService.get('/api/pets/${booking['accountId']}/${booking['petId']}');
      if (petResponse.statusCode == 200) {
        var petJson = jsonDecode(utf8.decode(petResponse.bodyBytes));
        booking['petDetails'] = petJson['data'];
      }
    }

    setState(() {
      _showAllBookings();
    });
  }

  void _showAllBookings() {
    setState(() {
      filteredBookings = bookings;
      showAllBookings = true;
    });
  }

  void _filterBookingsByDate(String date) {
    setState(() {
      filteredBookings = bookings.where((booking) => DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['bookedDate'])) == date).toList();
      showAllBookings = false;

      // Kiểm tra nếu không có booking nào cho ngày được chọn
      if (filteredBookings.isEmpty) {
        // Utils.noti("No bookings for this day");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: const Navbar(
        title: "Booking History",
      ),
      drawer: const MaterialDrawer(currentPage: "/spa-booking"),
      body: bookings.isEmpty
          ? const Center(
              child: Text('No bookings found.'),
            )
          : Column(
              children: [
                Expanded(
                  child: filteredBookings.isEmpty
                      ? const Center(child: Text("No bookings for this day"))
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              var booking = filteredBookings[index];
                              var productDetails = booking['productDetails'] ?? {};
                              var petDetails = booking['petDetails'] ?? {};

                              return GestureDetector(
                                onTap: () {
                                  Utils.navigateTo(
                                    context,
                                    SpaBookingDetailScreen(bookingId: booking['id']),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Booking #${booking['id']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Service: ${productDetails['name'] ?? 'N/A'}'),
                                        Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['bookedDate']))}'),
                                        Text('Time: ${booking['usedTime']}'),
                                        Text('Pet: ${petDetails['name'] ?? 'N/A'}'),
                                        Text('Status: ${booking['status']}'),
                                        const SizedBox(height: 16),
                                        booking['status'] == 'Pending'
                                            ? Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      Utils.confirmDialog(
                                                        context,
                                                        'Cancel Booking',
                                                        'Are you sure you want to cancel this booking?',
                                                        () async {
                                                          await _cancelBooking(booking['id'].toString());
                                                        },
                                                        cancelText: 'Let me think again',
                                                        confirmText: 'Yes, cancel it',
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: MaterialColors.error,
                                                    ),
                                                    child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
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
                ),
                const Divider(),
                _buildCalendar(),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    List<String> bookedDates = bookings.map((booking) => DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['bookedDate']))).toList();

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last 31 days bookings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _showAllBookings,
                child: const Text('Show All Bookings'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDateGrid(bookedDates),
        ],
      ),
    );
  }

  Widget _buildDateGrid(List<String> bookedDates) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.5,
      ),
      itemCount: 31,
      itemBuilder: (context, index) {
        DateTime currentDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index+1));
        String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
        bool isBooked = bookedDates.contains(formattedDate);
        bool isSelected = formattedDate == selectedDate;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = formattedDate;
              _filterBookingsByDate(formattedDate);
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : (isBooked ? Colors.green : Colors.white),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey),
            ),
            alignment: Alignment.center,
            child: Text(
              DateFormat('d').format(currentDate),
              style: TextStyle(
                color: isSelected ? Colors.white : (isBooked ? Colors.white : Colors.black),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
