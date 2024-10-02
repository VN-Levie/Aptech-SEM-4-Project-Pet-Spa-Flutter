import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';

//widgets
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/widgets/photo-album.dart';
import 'package:project/widgets/utils.dart';

class PetInfo extends StatefulWidget {
  final int id;
  const PetInfo({super.key, required this.id});
  @override
  _PetInfoState createState() => _PetInfoState();
}

class _PetInfoState extends State<PetInfo> {
  final AppController appController = Get.put(AppController());

  late Map<String, dynamic> pet = {}; // Khai báo biến pet để lưu thông tin thú cưng
  late List<String> imgArray = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchPetDetails(widget.id);
  }

  // Hàm lấy thông tin pet từ API
  Future<void> _fetchPetDetails(int petId) async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });
    int accountId = appController.account.id;
    try {     
      var response = await RestService.get('/api/pets/$accountId/$petId');     
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var data = jsonResponse['data'];

        if (data['deleted'] == true || data.isEmpty) {
          Utils.noti('Pet not found');
          Navigator.pop(context, 'update');
        } else {
          Map<String, dynamic> pet = Map<String, dynamic>.from(data);          
          response = await RestService.get('/api/pets/$petId/photos'); // Gọi API để lấy thông tin hình ảnh của thú cưng
          List<String> imgArrayLoad = [];         
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            var data = jsonResponse['data'];

            for (var item in data) {
              imgArrayLoad.add(item['photoUrl']);
            }
          }
          setState(() {
            this.pet = pet;
            imgArray = imgArrayLoad;
            _isLoading = false;
          });
        }
      } else {
        Utils.noti('Pet not found!');
        Navigator.pop(context, 'update');
      }
    } catch (e) {
      Utils.noti('Pet not found.');
      Navigator.pop(context, 'update');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: Navbar(
          title: 'Pet detail', // Hiển thị tên thú cưng
          transparent: true,
          rightOptions: false,
          backButton: true,
        ),
        backgroundColor: MaterialColors.bgColorScreen,
        drawer: const MaterialDrawer(currentPage: "PetInfo"),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: NetworkImage(Utils.replaceLocalhost(pet!['avatarUrl'])), // Ảnh chính của thú cưng
                      fit: BoxFit.cover)),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.center, end: Alignment.bottomCenter, colors: [
                Colors.black.withOpacity(0),
                Colors.black.withOpacity(0.9),
              ])),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.50,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${pet!['name']}',
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                      overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                      maxLines: 1, // Giới hạn tên hiển thị trên 1 dòng
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MaterialColors.label), child: const Text("Pet Info", style: TextStyle(color: Colors.white, fontSize: 16))),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text("Height: ${pet!['height']} cm | Weight: ${pet!['weight']} kg", style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                        BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 8, blurRadius: 10, offset: const Offset(0, 0))
                      ],
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(13.0),
                        topRight: Radius.circular(13.0),
                      )),
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.58,
                  ),
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description:",
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            const SizedBox(height: 6),
                            Text(pet!['description'] ?? 'No description provided', style: const TextStyle(color: MaterialColors.muted)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PhotoAlbum(imgArray: imgArray)
                      ],
                    ),
                  )),
            )
          ],
        ));
  }

  
}
