import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/pet_tag_dto.dart';
import 'package:project/models/spa_category.dart';
import 'package:project/widgets/list_pet_tag.dart';
import 'package:project/widgets/list_spa_category.dart';
import 'package:project/widgets/utils.dart';
import 'service_selection.dart';
import '../../core/database_helper.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/theme.dart';

class PetTagScreen extends StatefulWidget {
  const PetTagScreen({super.key});

  @override
  _PetTagScreenState createState() => _PetTagScreenState();
}

class _PetTagScreenState extends State<PetTagScreen> {
  List<Map<String, String>> _imgArray = [];

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  _loadCategories() async {
    final String apiUrl = '/api/pet-tags';
    try {
      var response = await RestService.get(apiUrl);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        var data = jsonResponse['data'];
        print(data);
        List<PetTagDTO> categories = [];
        List<Map<String, String>> imgArray = [];
        if (data.isNotEmpty) {
          categories.addAll(List<PetTagDTO>.from(data.map((x) => PetTagDTO.fromJson(x))));
        }

        //đưa ảnh vào mảng
        for (var i = 0; i < categories.length; i++) {
          imgArray.add({
            "id": categories[i].id.toString(),
            "img": Utils.replaceLocalhost(categories[i].iconUrl),
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
        appBar: const Navbar(
          title: "Accessories",
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        // key: _scaffoldKey,
        drawer: const MaterialDrawer(currentPage: "/customization"),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: const Navbar(
        title: "Accessories",
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      // key: _scaffoldKey,
      drawer: const MaterialDrawer(currentPage: "/customization"),
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: PetTagCarousel(imgArray: _imgArray),
      ),
    );
  }
}
