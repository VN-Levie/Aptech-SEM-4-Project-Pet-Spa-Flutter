import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RentPetHotel extends StatefulWidget {
  const RentPetHotel({super.key});

  @override
  _RentPetHotelState createState() => _RentPetHotelState();
}

class _RentPetHotelState extends State<RentPetHotel> {
  final _petNameController = TextEditingController();
  final _locationController = TextEditingController(); // Controller cho địa chỉ vị trí
  String _azureMapsApiKey = 'YOUR_AZURE_MAPS_API_KEY';  // Thay bằng Azure Maps API key của bạn

  // Lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Lấy địa chỉ từ latitude và longitude
    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  // Chuyển đổi từ lat, lon thành địa chỉ thông qua Azure Maps API
  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    String url =
        'https://atlas.microsoft.com/search/address/reverse/json?subscription-key=$_azureMapsApiKey&api-version=1.0&query=$latitude,$longitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String address = data['addresses'][0]['address']['freeformAddress'];

      setState(() {
        _locationController.text = address; // Điền địa chỉ tự động vào TextField
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get address from Azure Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rent Pet Hotel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Pet Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _petNameController,
              decoration: const InputDecoration(
                labelText: 'Enter Pet Name',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Location Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Pickup/Drop Location',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text("Get Current Location"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_petNameController.text.isEmpty || _locationController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                // Xử lý logic xác nhận booking tại đây
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking confirmed!')),
                );
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
