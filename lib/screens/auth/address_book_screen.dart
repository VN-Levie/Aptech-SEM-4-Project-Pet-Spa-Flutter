import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/auth/address_book_form_screen.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/theme.dart';
import 'package:project/widgets/utils.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final AppController appController = Get.put(AppController());
  List<Map<String, dynamic>> addressBooks = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int offset = 0;
  int limit = 10;

  @override
  void initState() {
    super.initState();
    _loadAddressBooksFromAPI();
  }

  Future<void> _loadAddressBooksFromAPI({bool isRefresh = false}) async {
    setState(() {
      isLoading = true;
    });
    int accountId = appController.account.id;
    if (isRefresh) {
      offset = 0;
      addressBooks.clear();
      hasMore = true;
    }

    final String apiUrl = '/api/address-books/account/$accountId';

    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        if (data.isNotEmpty) {
          setState(() {
            addressBooks.addAll(List<Map<String, dynamic>>.from(data));
            offset += limit;
          });
        } else {
          setState(() {
            hasMore = false;
          });
        }
      } else {
        Utils.noti("Failed to load address books: ${response.statusCode}");
      }
    } catch (e) {
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

  Future<void> _deleteAddressBook(int addressBookId, int index) async {
    final String apiUrl = '/api/address-books/$addressBookId';
    try {
      var response = await RestService.delete(apiUrl);
      if (response.statusCode == 200) {
        Utils.noti("Address deleted successfully!");
        setState(() {
          addressBooks.removeAt(index);
        });
        appController.setAddressBook(appController.addressBook.value - 1);
      } else if (response.statusCode == 404) {
        Utils.noti("Address not found!");
      } else {
        Utils.noti("Failed to delete address book: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting address: $e')),
      );
    }
  }

  Future<void> _refreshAddressBooks() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      await _loadAddressBooksFromAPI(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        backButton: true,
        title: 'Your Address Books',
        searchBar: false,
        rightOptions: false,
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      drawer: const MaterialDrawer(currentPage: "/address_book_screen"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Utils.navigateTo(context, const AddressBookFormScreen());
                  if (result == 'success' || result == 'update') {
                    _refreshAddressBooks();
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
                  'Add New Address',
                  style: TextStyle(fontSize: 16, color: MaterialColors.caption),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshAddressBooks,
                  child: addressBooks.isEmpty && !isLoading
                      ? Center(
                          child: Text(
                            'No address books found. Click the button above to add a new address.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: addressBooks.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == addressBooks.length) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final addressBook = addressBooks[index];

                            return Dismissible(
                              key: Key(addressBook['id'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (direction) {
                                _deleteAddressBook(addressBook['id'], index);
                                setState(() {
                                  addressBooks.removeAt(index);
                                });
                              },
                              child: addressBookCard(context, addressBook, index),
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

  GestureDetector addressBookCard(BuildContext context, Map<String, dynamic> addressBook, int index) {
    return GestureDetector(
      onTap: () {
        Utils.navigateTo(context, AddressBookFormScreen(addressBookId: addressBook['id']));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addressBook['street'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${addressBook['city']}, ${addressBook['state']} ${addressBook['postalCode']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      addressBook['country'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      final result = await Utils.navigateTo(context, AddressBookFormScreen(addressBookId: addressBook['id']));
                      if (result == 'success' || result == 'update') {
                        _refreshAddressBooks();
                      }
                    },
                    child: const Icon(Icons.edit, color: Colors.blue),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Utils.confirmDialog(
                        context,
                        'Delete Address',
                        'Are you sure you want to delete this address? \nThis action cannot be undone.',
                        () {
                          _deleteAddressBook(addressBook['id'], index);
                          setState(() {
                            addressBooks.removeAt(index);
                          });
                        },
                      );
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
