import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/spa_service.dart';
import 'package:project/screens/spa_booking/booking_history.dart';
import 'package:project/widgets/card_spa_service_small.dart';
import 'package:project/widgets/dropdown_input.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';
import 'package:intl/intl.dart';

class SpaConfirm extends StatefulWidget {
  final SpaService service;

  const SpaConfirm({super.key, required this.service});

  @override
  _SpaConfirmState createState() => _SpaConfirmState();
}

class _SpaConfirmState extends State<SpaConfirm> {
  List<Map<String, dynamic>> pets = [];
  List<Map<String, dynamic>> addressSuggestions = [];
  String? selectedPetId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _transportation = 'Self-drop-off'; // Tùy chọn pick-up
  String? _returnTransportation; // Tùy chọn trả pet
  String? _paymentMethod; // Tùy chọn phương thức thanh toán
  String? _address;
  bool isLoading = true;
  bool isLoadingLocation = false;
  bool isSearching = false;
  String? distanceInfo;
  String? travelTimeInfo;
  bool showDistanceAndTime = false; // Biến để kiểm soát hiển thị thời gian và khoảng cách
  bool isPaymentAtHomeAvailable = false; // Biến cho tùy chọn thanh toán tại nhà
  bool isPaymentAtStoreAvailable = false; // Biến cho tùy chọn thanh toán tại cửa hàng

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final AppController appController = Get.put(AppController());
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPetsFromAPI();
    _addressController.addListener(_onSearchAddressChanged);
  }

  @override
  void dispose() {
    _addressController.dispose();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPetsFromAPI() async {
    setState(() {
      isLoading = true;
    });
    int accountId = appController.account.id;

    final String apiUrl = '/api/pets/account/$accountId';

    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        if (data.isNotEmpty) {
          setState(() {
            pets = List<Map<String, dynamic>>.from(data);
            selectedPetId = pets.first['id'].toString();
          });
        } else {
          Utils.noti("Error: No pets found");
          Navigator.pop(context);
        }
      } else {
        Utils.noti("Error: No pets found");
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is SocketException) {
        Utils.noti("No internet connection");
      } else {
        Utils.noti("Something went wrong. Please try again later.");
      }
      Navigator.pop(context);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
      addressSuggestions.clear();
      showDistanceAndTime = false;
    });
    _addressController.removeListener(_onSearchAddressChanged);

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      );

      var response = await RestService.get('/api/map/get-address?lat=${position.latitude}&lon=${position.longitude}');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var address = jsonDecode(jsonResponse['data'])['addresses'][0]['address']['freeformAddress'];
        setState(() {
          _address = address;
          _addressController.text = _address!;
        });

        _calculateDistanceAndTime(position.latitude, position.longitude);
        Future.delayed(Duration(milliseconds: 200), () {
          _addressController.addListener(_onSearchAddressChanged);
        });
      } else {
        Utils.noti("Failed to get address.");
      }
    } catch (e) {
      Utils.noti("Failed to get current location.");
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<void> _calculateDistanceAndTime(double lat, double lon) async {
    try {
      var response = await RestService.get('/api/map/get-distance-and-time?userLat=$lat&userLon=$lon');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonDecode(jsonResponse['data']);
        var distanceInMeters = data['distanceInMeters'];
        var travelTimeInSeconds = data['travelTimeInSeconds'];
        var arrivalTime = data['arrivalTime'];

        int hours = travelTimeInSeconds ~/ 3600;
        int minutes = (travelTimeInSeconds % 3600) ~/ 60;

        var estimatedTime = DateTime.parse(arrivalTime).add(const Duration(minutes: 15));

        setState(() {
          distanceInfo = "Distance: ${(distanceInMeters / 1000).toStringAsFixed(2)} km";
          travelTimeInfo = "Travel Time: ${hours > 0 ? '$hours hr ' : ''}$minutes min";
          travelTimeInfo = "${travelTimeInfo ?? ''}\nEstimated Arrival Time: ${DateFormat('yyyy-MM-dd HH:mm').format(estimatedTime)}";
          showDistanceAndTime = true;
        });
      } else {
        Utils.noti("Failed to calculate distance and time.");
      }
    } catch (e) {
      Utils.noti("Error calculating distance and time.");
    }
  }

  void _onSearchAddressChanged() {
    setState(() {
      showDistanceAndTime = false;
    });

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (_addressController.text.isNotEmpty) {
        _searchAddress(_addressController.text);
      } else {
        setState(() {
          addressSuggestions.clear();
        });
      }
    });
  }

  Future<void> _searchAddress(String query) async {
    setState(() {
      isSearching = true;
      showDistanceAndTime = false;
    });

    try {
      var response = await RestService.get('/api/map/search-place?query=$query');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        var data = jsonDecode(jsonResponse['data'])['results'];
        setState(() {
          addressSuggestions = List<Map<String, dynamic>>.from(data);
        });
      } else {
        Utils.noti("Error fetching addresses.");
      }
    } catch (e) {
      Utils.noti("Error fetching addresses.");
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  // Logic kiểm tra hiển thị hộp thời gian và khoảng cách dựa trên pick-up
  bool _shouldShowDistanceAndTime() {
    return _transportation == 'Pick-up by staff';
  }

  // Logic kiểm tra tùy chọn thanh toán
  void _updatePaymentOptions() {
    isPaymentAtHomeAvailable = _transportation == 'Pick-up by staff' || _returnTransportation == 'Return by staff';
    isPaymentAtStoreAvailable = _transportation == 'Self-drop-off' || _returnTransportation == 'Self-return';
  }

  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  _bookService() async {
    if (selectedPetId == null) {
      Utils.noti("Please select a pet.");
      return;
    }
    if (_selectedDate == null) {
      Utils.noti("Please select a date.");
      return;
    }

    if (_selectedTime == null) {
      Utils.noti("Please select a time.");
      return;
    }

    if (_transportation == 'Pick-up by staff' && _addressController.text.isEmpty) {
      Utils.noti("Please enter a pick-up address.");
      return;
    }

    if (_returnTransportation == null) {
      Utils.noti("Please select a return transportation method.");
      return;
    }

    if (_paymentMethod == null) {
      Utils.noti("Please select a payment method.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String bookedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(_selectedDate!.toUtc());
      String usedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(_selectedDate!.toUtc());
      String usedTime = _selectedTime!.format(context);

      String pickupAddress = _transportation == 'Pick-up by staff' ? _addressController.text : 'Self-drop-off';
      String returnAddress = _returnTransportation == 'Return by staff' ? _addressController.text : 'Self-return';
      var response = await RestService.post('/api/spa/bookings', {
        'accountId': appController.account.id,
        'serviceId': widget.service.id,
        'petId': int.parse(selectedPetId!),
        'bookedDate': bookedDate,
        'usedDate': usedDate,
        'usedTime': usedTime,
        'price': widget.service.price,
        'pickUpType': _transportation,
        'returnType': _returnTransportation,
        'paymentType': _paymentMethod,
        'note': _note.text,
        'status': 'Pending',
        'pickUpAddress': pickupAddress,
        'returnAddress': returnAddress,
      });

      print(response.statusCode);

      if (response.statusCode == 201) {
        Utils.noti("Booking successful! Thak you for using our service. The staff will contact you soon.");
        //Navigator.pop(context);
        Utils.navigateTo(context, const BookingHistoryScreen());
      } else if (response.statusCode == 400) {
        // Xử lý lỗi 400: Dữ liệu không hợp lệ
        var jsonResponse = jsonDecode(response.body);
        Utils.noti(jsonResponse['message'] ?? 'Invalid input data');
      } else {
        // Xử lý các mã trạng thái khác
        var jsonResponse = jsonDecode(response.body);
        Utils.noti(jsonResponse['message'] ?? 'Failed to book service.');
      }
    } catch (e) {
      if (e is SocketException) {
        Utils.noti("Network error. Please check your connection.");
      } else {
        print(e);
        Utils.noti("Something went wrong. Please try again later.");
      }
      //Utils.noti("Failed to book service.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearSearch() {
    _addressController.clear();
    setState(() {
      addressSuggestions.clear();
      showDistanceAndTime = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: Navbar(title: 'Confirm Booking', backButton: true, rightOptions: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SpaServiceCardSmall(
                  title: widget.service.name,
                  img: widget.service.imageUrl,
                  description: widget.service.description,
                ),
              ),
              const SizedBox(height: 20),
              DropdownInput(
                placeholder: 'Select Pet',
                value: selectedPetId,
                items: pets.map((pet) {
                  return DropdownMenuItem<String>(
                    value: pet['id'].toString(),
                    child: Text('${pet['name']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPetId = value;
                  });
                },
              ),
              ListTile(
                title: Text(_selectedDate == null ? 'Select Date' : 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(_selectedTime == null ? 'Select Time' : 'Selected Time: ${_selectedTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: _pickTime,
              ),
              Text('Pickup By', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownInput(
                placeholder: 'Transportation Method (Pick-up)',
                value: _transportation,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'Self-drop-off', child: Text('Self-drop-off')),
                  DropdownMenuItem(value: 'Pick-up by staff', child: Text('Pick-up by staff')),
                ],
                onChanged: (value) {
                  setState(() {
                    _transportation = value!;
                    showDistanceAndTime = _shouldShowDistanceAndTime();
                    _updatePaymentOptions();
                  });
                },
              ),
              if (_transportation == 'Pick-up by staff')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Pick-up Address',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          ),
                        ),
                      ),
                      if (isSearching)
                        const CircularProgressIndicator()
                      else if (addressSuggestions.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: addressSuggestions.length > 5 ? 5 : addressSuggestions.length,
                          itemBuilder: (context, index) {
                            var suggestion = addressSuggestions[index];
                            return ListTile(
                              title: Text(suggestion['address']['freeformAddress']),
                              onTap: () {
                                _addressController.removeListener(_onSearchAddressChanged);
                                _addressController.text = suggestion['address']['freeformAddress'];
                                setState(() {
                                  addressSuggestions.clear();
                                });
                                _calculateDistanceAndTime(
                                  suggestion['position']['lat'],
                                  suggestion['position']['lon'],
                                );
                                Future.delayed(Duration(milliseconds: 100), () {
                                  _addressController.addListener(_onSearchAddressChanged);
                                });
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isLoadingLocation ? null : _getCurrentLocation,
                        icon: const Icon(Icons.location_on),
                        label: isLoadingLocation ? const CircularProgressIndicator() : const Text('Use Current Location'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              if (showDistanceAndTime)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(top: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (distanceInfo != null)
                        Text(
                          distanceInfo!,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (travelTimeInfo != null)
                        Text(
                          travelTimeInfo!,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Please note that this is only an estimated time, and the actual time may vary depending on when the staff accepts the booking and starts traveling.',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Text('Drop-off By', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownInput(
                placeholder: 'Transportation Method (Return)',
                value: _returnTransportation,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'Self-return', child: Text('Self-return')),
                  DropdownMenuItem(value: 'Return by staff', child: Text('Return by staff')),
                ],
                onChanged: (value) {
                  setState(() {
                    _returnTransportation = value!;
                    _updatePaymentOptions();
                  });
                },
              ),
              const SizedBox(height: 20),
              Text('Payment Options', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownInput(
                placeholder: 'Select Payment Method',
                value: isPaymentAtHomeAvailable ? 'payment-at-home' : (isPaymentAtStoreAvailable ? 'payment-at-store' : null),
                items: <DropdownMenuItem<String>>[
                  if (isPaymentAtHomeAvailable) DropdownMenuItem(value: 'payment-at-home', child: Text('Pay at home')),
                  if (isPaymentAtStoreAvailable) DropdownMenuItem(value: 'payment-at-store', child: Text('Pay at store')),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                  print(_paymentMethod);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _note,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                ),
              ),
              ElevatedButton(
                onPressed: _bookService,
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
