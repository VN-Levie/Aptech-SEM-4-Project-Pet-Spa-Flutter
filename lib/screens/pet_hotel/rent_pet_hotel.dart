import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/pet_hotel/hotel_booking_history_screen.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class RentPetHotel extends StatefulWidget {
  const RentPetHotel({super.key});

  @override
  _RentPetHotelState createState() => _RentPetHotelState();
}

class _RentPetHotelState extends State<RentPetHotel> {
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  double _pricePerDay = 15.0;
  double _totalPrice = 0.0;

  List<Map<String, dynamic>> pets = [];
  List<Map<String, dynamic>> addressSuggestions = [];
  String? selectedPetId;
  bool isLoadingPets = true;
  bool isSearching = false;
  bool isLoadingLocation = false;
  String? _pickUpMethod = 'Self-drop-off';
  String? _returnMethod;
  String? _paymentMethod = 'payment-at-store';
  String? distanceInfo;
  String? travelTimeInfo;
  bool showDistanceAndTime = false;
  bool isPaymentAtHomeAvailable = false;
  bool isPaymentAtStoreAvailable = false;

  final AppController appController = Get.put(AppController());

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadPetsFromAPI();
    _locationController.addListener(_onSearchAddressChanged);
  }

  @override
  void dispose() {
    _locationController.dispose();
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPetsFromAPI() async {
    setState(() {
      isLoadingPets = true;
    });

    final String apiUrl = '/api/pets/account/${appController.account.id}';
    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        setState(() {
          pets = List<Map<String, dynamic>>.from(data);
          selectedPetId = pets.isNotEmpty ? pets.first['id'].toString() : null;
        });
      } else {
        Utils.noti("Error: No pets found");
      }
    } catch (e) {
      if (e is SocketException) {
        Utils.noti("No internet connection");
      } else {
        Utils.noti("Something went wrong. Please try again later.");
      }
    } finally {
      setState(() {
        isLoadingPets = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
      addressSuggestions.clear();
      showDistanceAndTime = false;
    });
    _locationController.removeListener(_onSearchAddressChanged);

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      );

      var response = await RestService.get(
          '/api/map/get-address?lat=${position.latitude}&lon=${position.longitude}');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var address = jsonDecode(jsonResponse['data'])['addresses'][0]['address']['freeformAddress'];
        setState(() {
          _locationController.text = address;
        });
        _calculateDistanceAndTime(position.latitude, position.longitude);
        Future.delayed(const Duration(milliseconds: 200), () {
          _locationController.addListener(_onSearchAddressChanged);
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
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (_locationController.text.isNotEmpty) {
        _searchAddress(_locationController.text);
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

  void _pickDate(BuildContext context, bool isCheckIn) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = pickedDate;
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
            _checkOutDate = null;
          }
        } else {
          if (_checkInDate != null && pickedDate.isAfter(_checkInDate!)) {
            _checkOutDate = pickedDate;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check-out date must be after check-in date')),
            );
          }
        }
        _calculateTotalPrice();
      });
    }
  }

  void _calculateTotalPrice() {
    if (_checkInDate != null && _checkOutDate != null) {
      Duration difference = _checkOutDate!.difference(_checkInDate!);
      int totalDays = (difference.inHours / 24).ceil();
      _totalPrice = totalDays * _pricePerDay;
    }
  }

  void _updatePaymentOptions() {
    isPaymentAtHomeAvailable = _pickUpMethod == 'Pick-up by staff' || _returnMethod == 'Return by staff';
    isPaymentAtStoreAvailable = _pickUpMethod == 'Self-drop-off' || _returnMethod == 'Self-return';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(
        title: "Rent Pet Hotel",
      ),
      drawer: const MaterialDrawer(currentPage: "/hotel"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter Pet Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              isLoadingPets
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Pet'),
                      value: selectedPetId,
                      items: pets.map((pet) {
                        return DropdownMenuItem<String>(
                          value: pet['id'].toString(),
                          child: Text(pet['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPetId = value;
                        });
                      },
                    ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(_checkInDate == null
                    ? 'Select Check-in Date'
                    : 'Check-in Date: ${DateFormat('yyyy-MM-dd').format(_checkInDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, true),
              ),
              ListTile(
                title: Text(_checkOutDate == null
                    ? 'Select Check-out Date'
                    : 'Check-out Date: ${DateFormat('yyyy-MM-dd').format(_checkOutDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context, false),
              ),
              const SizedBox(height: 20),
              Text('Total Price: \$${_totalPrice.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pick-up Method',
                ),
                value: _pickUpMethod,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'Self-drop-off', child: Text('Self-drop-off')),
                  DropdownMenuItem(value: 'Pick-up by staff', child: Text('Pick-up by staff')),
                ],
                onChanged: (value) {
                  setState(() {
                    _pickUpMethod = value!;
                    _updatePaymentOptions();
                  });
                },
              ),
              if (_pickUpMethod == 'Pick-up by staff')
                Column(
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Pick-up Address',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                    if (addressSuggestions.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: addressSuggestions.length > 5 ? 5 : addressSuggestions.length,
                        itemBuilder: (context, index) {
                          var suggestion = addressSuggestions[index];
                          return ListTile(
                            title: Text(suggestion['address']['freeformAddress']),
                            onTap: () {
                              _locationController.removeListener(_onSearchAddressChanged);
                              _locationController.text = suggestion['address']['freeformAddress'];
                              setState(() {
                                addressSuggestions.clear();
                              });
                              _calculateDistanceAndTime(
                                suggestion['position']['lat'],
                                suggestion['position']['lon'],
                              );
                              Future.delayed(const Duration(milliseconds: 100), () {
                                _locationController.addListener(_onSearchAddressChanged);
                              });
                            },
                          );
                        },
                      ),
                    ElevatedButton.icon(
                      onPressed: isLoadingLocation ? null : _getCurrentLocation,
                      icon: const Icon(Icons.location_on),
                      label: isLoadingLocation ? const CircularProgressIndicator() : const Text('Use Current Location'),
                    ),
                    if (showDistanceAndTime)
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(distanceInfo ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(travelTimeInfo ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Return Method',
                ),
                value: _returnMethod,
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'Self-return', child: Text('Self-return')),
                  DropdownMenuItem(value: 'Return by staff', child: Text('Return by staff')),
                ],
                onChanged: (value) {
                  setState(() {
                    _returnMethod = value!;
                    _updatePaymentOptions();
                  });
                },
              ),
              const SizedBox(height: 20),
              Text('Payment Options', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Payment Method',
                ),
                value: isPaymentAtHomeAvailable
                    ? 'payment-at-home'
                    : (isPaymentAtStoreAvailable ? 'payment-at-store' : null),
                items: <DropdownMenuItem<String>>[
                  if (isPaymentAtHomeAvailable) DropdownMenuItem(value: 'payment-at-home', child: Text('Pay at home')),
                  if (isPaymentAtStoreAvailable) DropdownMenuItem(value: 'payment-at-store', child: Text('Pay at store')),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (selectedPetId == null ||                     
                      _checkInDate == null ||
                      _checkOutDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  // Gọi API để đặt hotel cho pet
                  try {
                    String checkInDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(_checkInDate!.toUtc());
                    String checkOutDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(_checkOutDate!.toUtc());

                    var response = await RestService.post('/api/hotel-bookings', {
                      'accountId': appController.account.id,
                      'petId': int.parse(selectedPetId!),
                      'checkInDate': checkInDate,
                      'checkOutDate': checkOutDate,
                      'totalPrice': _totalPrice,
                      'pickUpType': _pickUpMethod,
                      'returnType': _returnMethod,
                      'paymentType': _paymentMethod,
                      'pickUpAddress': _locationController.text,
                      'returnAddress': _locationController.text,
                      'note': _noteController.text,
                      'status': 'Pending',
                    });

                    if (response.statusCode == 201) {
                      Utils.noti("Hotel booking successful!");
                     Utils.navigateTo(context, const HotelBookingHistoryScreen());
                    } else {
                      var jsonResponse = jsonDecode(response.body);
                      Utils.noti(jsonResponse['message'] ?? 'Failed to book hotel.');
                    }
                  } catch (e) {
                    if (e is SocketException) {
                      Utils.noti("Network error. Please check your connection.");
                    } else {
                      print(e);
                      Utils.noti("Something went wrong. Please try again later.");
                    }
                  }
                },
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
