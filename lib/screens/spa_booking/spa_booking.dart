import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/spa_category.dart';
import 'package:project/widgets/list_spa_category.dart';
import 'package:project/widgets/utils.dart';
import 'service_selection.dart';
import '../../core/database_helper.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/theme.dart';

class SpaBooking extends StatefulWidget {
  const SpaBooking({super.key});

  @override
  _SpaBookingState createState() => _SpaBookingState();
}

class _SpaBookingState extends State<SpaBooking> {
  List<Map<String, String>> _imgArray = [];

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _loadCategories() async {
    final String apiUrl = '/api/spa/categories';
    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var data = jsonResponse['data'];
        //print(data);
        List<SpaCategory> categories = [];
        List<Map<String, String>> imgArray = [];
        if (data.isNotEmpty) {
          categories.addAll(List<SpaCategory>.from(data.map((x) => SpaCategory.fromJson(x))));
        }

        //đưa ảnh vào mảng
        for (var i = 0; i < categories.length; i++) {
          imgArray.add({
            "id": categories[i].id.toString(),
            "img": categories[i].imageUrl,
            "name": categories[i].name,
            "description": categories[i].description,
          });
        }
        setState(() {
          _imgArray = imgArray;
        });
      } else {
        Utils.noti("Failed to load pets: ${response.statusCode}");
      }
    } catch (e) {
      //kiểm tra mạng
      if (e is SocketException) {
        Utils.noti("No internet connection");
      } else {
        ///print(e);
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
        appBar: const Navbar(
          title: "Spa Booking",
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: const MaterialDrawer(currentPage: "/booking"),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: const Navbar(
        title: "Spa Booking",
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      drawer: const MaterialDrawer(currentPage: "/booking"),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: SpaCategoryCarousel(imgArray: _imgArray),
      ),
    );
  }
}
