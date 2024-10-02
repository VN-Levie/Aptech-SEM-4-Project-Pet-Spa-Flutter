import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/spa_service.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/pets/pet_form_screen.dart';
import 'package:project/screens/spa_booking/spa_confirm.dart';
import 'package:project/widgets/card_spa_service.dart';
import 'package:project/widgets/utils.dart';

import 'package:project/widgets/navbar.dart';
import 'package:project/constants/theme.dart';

class ServiceSelection extends StatefulWidget {
  final int categoryId;
  const ServiceSelection({super.key, required this.categoryId});

  @override
  _ServiceSelectionState createState() => _ServiceSelectionState();
}

class _ServiceSelectionState extends State<ServiceSelection> {
  final List<SpaService> _services = [];
  bool isLoading = true;

  final AppController appController = Get.put(AppController());

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  _loadServices() async {
    String apiUrl = '/api/spa/products/${widget.categoryId}';
    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var data = jsonResponse['data'];

        //  [{id: 1, name: Bath & Coat Conditioning, price: 30.0, imageUrl: https://via.placeholder.com/500?text=Bath+&+Coat+Conditioning, category: 1, description: Cleanse, massage, and condition pet's coat for smooth and shiny fur.}, {id: 2, name: Haircut & Trimming, price: 40.0, imageUrl: https://via.placeholder.com/500?text=Haircut+&+Trimming, category: 1, description: Trim and style pet's fur to keep it neat and tidy.}, {id: 3, name: Special Coat Care, price: 50.0, imageUrl: https://via.placeholder.com/500?text=Special+Coat+Care, category: 1, description: Detangle and groom for long or easily matted coats.}]

        if (data.isNotEmpty) {
          setState(() {
            _services.addAll(List<SpaService>.from(data.map((x) => SpaService.fromJson(x))));
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
        print(e);
        Utils.noti("Something went wrong. Please try again later.");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: const Navbar(
        title: "Select Service",
        backButton: true,
        rightOptions: false,
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 5.0, right: 5.0),
        child: ListView.builder(
          itemCount: _services.length,
          itemBuilder: (context, index) {
            return CardSpaService(
              service: _services[index],
              onTap: () {
                if (!appController.isAuthenticated.value) {
                  Utils.confirmDialog(
                    context,
                    "Login Required",
                    "This feature needs a logged-in account.",
                    () {
                      Utils.navigateTo(context, const LoginScreen());
                    },
                    confirmText: "Login Now",
                    cancelText: "Not Now",
                  );
                  return;
                }

                if (appController.petCount.value == 0) {
                  Utils.confirmDialog(
                    context,
                    "No Pets Found",
                    "You need to have at least one pet to use this feature.",
                    () {
                      Utils.navigateTo(context, const PetFormScreen());
                    },
                    confirmText: "Add Pet",
                    cancelText: "Not Now",
                  );
                  return;
                }

                Utils.navigateTo(context, SpaConfirm(service: _services[index]));
              },
            );
          },
        ),
      ),
    );
  }
}
