import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/widgets/input.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class AddressBookFormScreen extends StatefulWidget {
  final int? addressBookId;

  const AddressBookFormScreen({super.key, this.addressBookId});

  @override
  _AddressBookFormScreenState createState() => _AddressBookFormScreenState();
}

class _AddressBookFormScreenState extends State<AddressBookFormScreen> {
  final AppController appController = Get.put(AppController());
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isEditMode = false;
  bool isSearching = false;
  Timer? _debounce;
  List<Map<String, dynamic>> addressSuggestions = [];

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _countryController.text = 'Vietnam';
    _postalCodeController.text = '700000';
    _fullNameController.text = appController.account.name;
    _emailController.text = appController.account.email;
    if (widget.addressBookId != null) {
      _isEditMode = true;
      _fetchAddressBookDetails(widget.addressBookId!);
    }
  }

  void _onSearchAddressChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 950), () {
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
    });

    try {
      var response = await RestService.get('/api/map/search-place?query=$query');
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        var data = jsonDecode(jsonResponse['data'])['results'];
        setState(() {
          addressSuggestions = data.map<Map<String, dynamic>>((result) {
            String? streetNumberStr = result['address']?['streetNumber'];
            String streetName = streetNumberStr != null && streetNumberStr.isNotEmpty ? '$streetNumberStr, ${result['address']?['streetName'] ?? ''}' : result['address']?['streetName'] ?? '';

            return {
              'name': result['address']['freeformAddress'],
              'street': streetName,
              'city': result['address']['municipality'],
              'state': result['address']['countrySubdivision'],
              'postalCode': result['address']['postalCode'],
              'country': result['address']['country'],
            };
          }).toList();
        });
      } else {
        Utils.noti("Error fetching addresses.");
      }
    } catch (e) {
      print(e);
      Utils.noti("Error fetching addresses.");
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> _fetchAddressBookDetails(int addressBookId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var response = await RestService.get('/api/address-books/$addressBookId');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        var data = jsonResponse['data'];

        if (data.isEmpty) {
          Utils.noti('Address not found');
          Navigator.pop(context, 'update');
        } else {
          _streetController.text = data['street'];
          _cityController.text = data['city'];
          _stateController.text = data['state'];
          _postalCodeController.text = data['postalCode'];
          _countryController.text = data['country'];
          _fullNameController.text = data['fullName'] ?? '';
          _phoneNumberController.text = data['phoneNumber'] ?? '';
          _emailController.text = data['email'] ?? '';
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        Utils.noti('Address not found!');
        Navigator.pop(context, 'update');
      }
    } catch (e) {
      Utils.noti('Address not found.');
      Navigator.pop(context, 'update');
    }
  }

  Future<void> _updateAddressBook() async {
    if (_formKey.currentState!.validate()) {
      String street = _streetController.text;
      String city = _cityController.text;
      String state = _stateController.text;
      String postalCode = _postalCodeController.text;
      String country = _countryController.text;

      var apiUrl = '/api/address-books/${widget.addressBookId}';
      var body = {
        'street': street,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'fullName': _fullNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
      };

      var response = await RestService.put(apiUrl, body);

      if (response.statusCode == 200) {
        Utils.noti('Address updated successfully');
        Navigator.pop(context, 'success');
      } else {
        Utils.noti('Something went wrong. Please try again later.');
      }
    } else {
      Utils.noti('Please fill in all required fields');
    }
  }

  Future<void> _addAddressBook() async {
    if (_formKey.currentState!.validate()) {
      String street = _streetController.text;
      String city = _cityController.text;
      String state = _stateController.text;
      String postalCode = _postalCodeController.text;
      String country = _countryController.text;
      int accountId = appController.account.id;

      var apiUrl = '/api/address-books';
      var body = {
        'street': street,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'fullName': _fullNameController.text,
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'accountId': accountId,
      };

      var response = await RestService.post(apiUrl, body);

      if (response.statusCode == 201) {
        Utils.noti('Address added successfully');
        appController.setAddressBook(appController.addressBook.value + 1);
        Navigator.pop(context, 'success');
      } else if (response.statusCode == 400) {
        var message = jsonDecode(response.body)['message'];
        Utils.noti(message);
      } else {
        Utils.noti('Something went wrong. Please try again later.');
      }
    } else {
      Utils.noti('Please fill in all required fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: _isEditMode ? 'Edit Address' : 'Add New Address',
        backButton: true,
        rightOptions: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Input(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _addressController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _addressController.clear()),
                              )
                            : null,

                        autofocus: true,
                        placeholder: 'Search Address',
                        controller: _addressController,
                        // outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        onChanged: _onSearchAddressChanged,
                      ),
                      if (isSearching) const CircularProgressIndicator(),
                      if (addressSuggestions.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: addressSuggestions.length,
                          itemBuilder: (context, index) {
                            var suggestion = addressSuggestions[index];
                            return ListTile(
                              title: Text(suggestion['name']),
                              onTap: () {
                                setState(() {
                                  _addressController.text = suggestion['name'];
                                  _streetController.text = suggestion['street'];
                                  _cityController.text = suggestion['city'];
                                  _stateController.text = suggestion['state'];
                                  _postalCodeController.text = suggestion['postalCode'];
                                  _countryController.text = suggestion['country'];
                                  addressSuggestions.clear();
                                });
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.directions),
                        placeholder: 'Street',
                        controller: _streetController,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter street';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.location_city),
                        placeholder: 'City',
                        controller: _cityController,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter city';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.map),
                        placeholder: 'State',
                        controller: _stateController,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter state';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.local_post_office),
                        placeholder: 'Postal Code',
                        controller: _postalCodeController,
                        keyboardType: TextInputType.number,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.muted,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter postal code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.public),
                        placeholder: 'Country',
                        controller: _countryController,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter country';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.person),
                        placeholder: 'Full Name',
                        controller: _fullNameController,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.phone),
                        placeholder: 'Phone Number',
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Input(
                        prefixIcon: const Icon(Icons.email),
                        placeholder: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        outlineBorder: true,
                        enabledBorderColor: MaterialColors.placeholder,
                        focusedBorderColor: MaterialColors.primary,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isEditMode ? _updateAddressBook : _addAddressBook,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: MaterialColors.primary.withOpacity(0.9),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          icon: Icon(_isEditMode ? Icons.edit : Icons.add, color: MaterialColors.caption),
                          label: Text(_isEditMode ? 'Update Address' : 'Add Address', style: const TextStyle(color: MaterialColors.caption)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
