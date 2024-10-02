import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/account.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/pets/list_pet.dart';

//widgets
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/widgets/photo-album.dart';
import 'package:project/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

List<String> imgArray = [
  "https://images.unsplash.com/photo-1508264443919-15a31e1d9c1a?fit=crop&w=240&q=80",
  "https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?fit=crop&w=240&q=80",
  "https://images.unsplash.com/photo-1487376480913-24046456a727?fit=crop&w=240&q=80",
  "https://images.unsplash.com/photo-1494894194458-0174142560c0?fit=crop&w=240&q=80",
  "https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?fit=crop&w=240&q=80",
  "https://images.unsplash.com/photo-1542068829-1115f7259450?fit=crop&w=240&q=80"
];

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late SharedPreferences prefs;
  late Account account = appController.account;
  final AppController appController = Get.put(AppController());
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    prefs = await SharedPreferences.getInstance();   
    final String apiUrl = '/api/pets/count/${account.id}';
    try {
      var response = await RestService.get(apiUrl);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
         appController.setPetCount(jsonResponse['data']);       
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: Navbar(
        title: "Profile",
        transparent: false,
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      drawer: const MaterialDrawer(currentPage: "/profile"),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: const BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.topCenter,
                image: AssetImage("assets/img/banner.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.12,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            account.name,
                            style: TextStyle(fontSize: 28, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: MaterialColors.label,
                            ),
                            child: Text(
                              account.roles == "ROLE_USER" ? 'Customer' : 'Loyal customer',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 8,
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  )
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13.0),
                  topRight: Radius.circular(13.0),
                ),
              ),
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.17,
              ),
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Utils.navigateTo(context, HomeScreen());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "36",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Orders",
                                      style: TextStyle(
                                        color: MaterialColors.muted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: MaterialColors.active,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Utils.navigateTo(context, HomeScreen());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "5",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Bids & Offers",
                                      style: TextStyle(
                                        color: MaterialColors.muted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: MaterialColors.active,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Utils.navigateTo(context, HomeScreen());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "2",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Messages",
                                      style: TextStyle(
                                        color: MaterialColors.muted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: MaterialColors.active,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          title: Text(
                            "Pets",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                             "${appController.petCount} Pets",
                            style: TextStyle(color: MaterialColors.muted),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Utils.navigateTo(context, PetScreen());
                          },
                        ),
                      ),
                      // Card(
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(10.0),
                      //   ),
                      //   child: ListTile(
                      //     title: Text(
                      //       "Photos",
                      //       style: TextStyle(fontWeight: FontWeight.bold),
                      //     ),
                      //     subtitle: Text(
                      //       "5 Photos",
                      //       style: TextStyle(color: MaterialColors.muted),
                      //     ),
                      //     trailing: Icon(Icons.arrow_forward_ios),
                      //     onTap: () {
                      //       Utils.navigateTo(context, HomeScreen());
                      //     },
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      PhotoAlbum(imgArray: imgArray),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
