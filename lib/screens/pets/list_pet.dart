import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/pets/pet_form_screen.dart';
import 'package:project/screens/pets/pet_info.dart';
import 'dart:async';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/theme.dart';
import 'package:project/widgets/utils.dart';

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  _PetScreenState createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final AppController appController = Get.put(AppController());
  List<Map<String, dynamic>> pets = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int offset = 0;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    _loadPetsFromAPI();
  }

  Future<void> _loadPetsFromAPI({bool isRefresh = false}) async {
    setState(() {
      isLoading = true;
    });
    int accountId = appController.account.id;
    if (isRefresh) {
      offset = 0;
      pets.clear();
      hasMore = true;
    }

    final String apiUrl = '/api/pets/account/$accountId';

    try {
      var response = await RestService.get(apiUrl);   
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        if (data.isNotEmpty) {
          setState(() {
            pets.addAll(List<Map<String, dynamic>>.from(data));
            offset += limit;
          });
        } else {
          setState(() {
            hasMore = false;
          });
        }
      } else {
        Utils.noti("Failed to load pets: ${response.statusCode}");
      }
    } catch (e) {
      //kiểm tra mạng
      if (e is SocketException) {
        Utils.noti("No internet connection");
      } else {
        Utils.noti("Something went wrong. Please try again later.");
      }
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

 
  //xóa thú cưng
  Future<void> _deletePet(int petId, int index) async {
    final String apiUrl = '/api/pets/$petId';
    try {
      var response = await RestService.delete(apiUrl);
      if (response.statusCode == 200) {
        Utils.noti("Pet deleted successfully!");
        try {
          String apiCount = '/api/pets/count/${appController.account.id}';
          var responseCount = await RestService.get(apiCount);
          if (responseCount.statusCode == 200) {
            var jsonResponse = jsonDecode(responseCount.body);
            appController.setPetCount(jsonResponse['data']);
          }
        } catch (e) {
          Utils.noti('Error while updating pet count');
        }
        //_refreshPets();
      } else if (response.statusCode == 404) {
        Utils.noti("Pet not found!");
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body)['message'];

        Utils.noti("Login failed: $jsonResponse");
      } else {
        Utils.noti("Failed to delete pet: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting pet: $e')),
      );
    }
  }

  Future<void> _refreshPets() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      await _loadPetsFromAPI(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        backButton: true,
        title: 'Your Pets',
        searchBar: false,
        rightOptions: false,
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      drawer: const MaterialDrawer(currentPage: "/pet_screen"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Utils.navigateTo(context, const PetFormScreen());
                  if (result == 'success' || result == 'update') {
                    _refreshPets();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: MaterialColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.add, color: MaterialColors.caption),
                label: const Text(
                  'Add New Pet',
                  style: TextStyle(fontSize: 16, color: MaterialColors.caption),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshPets,
                  child: pets.isEmpty && !isLoading // Kiểm tra xem danh sách có trống và không đang tải dữ liệu
                      ? Center(
                          child: Text(
                            'No pets found. Click the button above to add a new pet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: pets.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == pets.length) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final pet = pets[index];

                            // Sử dụng Dismissible để có hiệu ứng swipe to delete
                            return Dismissible(
                              key: Key(pet['id'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) {
                                _deletePet(pet['id'], index);
                                setState(() {
                                  pets.removeAt(index); // Xóa pet khỏi danh sách
                                });
                              },
                              child: petCard(context, pet, index), // Hiển thị thông tin pet
                            );
                          },
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  GestureDetector petCard(BuildContext context, Map<String, dynamic> pet, int index) {
    return GestureDetector(
      onTap: () {
        Utils.navigateTo(context, PetInfo(id: pet['id']));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  Utils.replaceLocalhost(pet['avatarUrl'] ?? ''),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Height: ${pet['height']} cm | Weight: ${pet['weight']} kg',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Căn phải cho các nút
                children: [
                  TextButton(
                    onPressed: () async {
                      final result = await Utils.navigateTo(context, PetFormScreen(petId: pet['id']));
                      if (result == 'success' || result == 'update') {
                        _refreshPets();
                      }
                    },
                    child: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  const SizedBox(height: 8), // Khoảng cách giữa nút "EDIT" và "DELETE"
                  TextButton(
                    onPressed: () {
                      // Xóa thú cưng
                      Utils.confirmDialog(context, 'Delete Pet', 'Are you sure you want to delete this pet? \nThis action cannot be undone.', () {
                        _deletePet(pet['id'], index);
                        setState(() {
                          pets.removeAt(index); // Xóa pet khỏi danh sách
                        });
                      });
                    },
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
