import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/account.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/onboarding_screen.dart';
import 'package:project/widgets/card-square.dart';
import 'package:project/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/card-horizontal.dart';
import 'package:project/widgets/card-small.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/widgets/slider-product.dart';
import 'dart:convert';

final Map<String, Map<String, String>> homeCards = {
  "Ice Cream": {
    "title": "Hardly Anything Takes More Coura...",
    "image": "assets/img/logo.jpg",
    "price": "180"
  },
  "Makeup": {
    "title": "Find the cheapest deals on our range...",
    "image": "https://images.unsplash.com/photo-1515709980177-7a7d628c09ba?crop=entropy&w=840&h=840&fit=crop",
    "price": "220"
  },
  "Coffee": {
    "title": "Looking for Men's watches?",
    "image": "https://images.unsplash.com/photo-1490367532201-b9bc1dc483f6?crop=entropy&w=840&h=840&fit=crop",
    "price": "40"
  },
  "Fashion": {
    "title": "Curious Blossom Skin Care Kit.",
    "image": "https://images.unsplash.com/photo-1536303006682-2ee36ba49592?crop=entropy&w=840&h=840&fit=crop",
    "price": "188"
  },
  "Argon": {
    "title": "Adjust your watch to your outfit.",
    "image": "https://images.unsplash.com/photo-1491336477066-31156b5e4f35?crop=entropy&w=840&h=840&fit=crop",
    "price": "180"
  }
};

List<Map<String, String>> imgArray = [
  {
    "img": "https://i.imgur.com/dWsS3PN.png",
    "title": "Ưu Đãi tháng 9",
    "description": "Ưu đãi giảm giá 50% cho tất cả các dịch vụ Spa",
  },
  {
    "title": "Ra Mắt Dịch Vụ Pet Hotel",
    "img": "https://i.imgur.com/0tXUr9P.jpeg",
    "description": "Dịch vụ Pet Hotel với giá cả hợp lý và chất lượng tốt nhất.",
  },
  {
    "title": "Free Cước Vận Chuyển",
    "img": "https://i.imgur.com/4Ko68lh.jpeg",
    "description": "Trong tháng 9, miễn phí cước vận chuyển cho tất cả các dịch vụ Spa",
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  @override
  void initState() {
    _isLoading = true;
    super.initState();
    _checkLoginStatus(); // Kiểm tra trạng thái đăng nhập khi khởi động màn hình
  }

  // Kiểm tra trạng thái đăng nhập dựa trên JWT token
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppController appController = Get.put(AppController());
    appController.loadCartData();
    //check is first time open app
    bool isFirstTime = prefs.getBool('first_time') ?? true;
    if (isFirstTime) {
      Utils.navigateTo(context, const OnboardingScreen());
      return;
    }
    FlutterSecureStorage storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt_token');
    String? refreshToken = await storage.read(key: 'refresh_token');
    print("token: $token");
    print("refresh token: $refreshToken");
    // Nếu token không tồn tại hoặc rỗng, chuyển hướng đến màn hình đăng nhập
    if (token != null && token.isNotEmpty && !appController.isAuthenticated.value) {
      try {
        String url = '/api/auth/verify-token?token=$token';
        var response = await RestService.get(url);
        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(response.body);
          var authData = jsonResponse['data'];

          // Trích xuất JWT từ AuthData
          String token = authData['jwt'];
          var accountJson = authData['account'];
          //  var accountJson = authData['account'];
          Account account = Account.fromJson(accountJson);
          await prefs.setString('jwt_token', token);
          await prefs.setString('account', jsonEncode(accountJson));

          appController.setIsAuthenticated(true);
          appController.setAccount(account);
          Utils.noti("Welcome back!");
          try {
            String apiCount = '/api/pets/count/${account.id}';
            var responseCount = await RestService.get(apiCount);
            if (responseCount.statusCode == 200) {
              var jsonResponse = jsonDecode(responseCount.body);
              appController.setPetCount(jsonResponse['data']);
            }
          } catch (e) {
            //Utils.noti('Error while updating pet count');
          }
          //Utils.navigateTo(context, const HomeScreen());
        } else if (response.statusCode == 400) {
          //trường hợp tk không tồn tại nữa
          //xóa jwt token
          await storage.delete(key: 'jwt_token');
          Utils.noti("Token expired. Please login again");
          Utils.navigateTo(context, const LoginScreen());
        } else if (response.statusCode == 401) {
          print("401 Unauthorized, trying to refresh token... at home");
          if (refreshToken == null) {
            Utils.noti("Token expired. Please login again!!");
            Utils.navigateTo(context, const LoginScreen());
          }
          var response = await RestService.post('/api/auth/refresh-token', {
            'refresh_token': refreshToken,
          });

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            var authData = jsonResponse['data'];

            // Trích xuất JWT từ AuthData
            String token = authData['jwt'];
            var account = authData['account'];

            // Lưu token vào SecureStorage

            await prefs.setString('account', jsonEncode(account));
            await storage.write(key: 'jwt_token', value: token);
            Utils.noti("Welcome back!");
            try {
              String apiCount = '/api/pets/count/${account.id}';
              var responseCount = await RestService.get(apiCount);
              if (responseCount.statusCode == 200) {
                var jsonResponse = jsonDecode(responseCount.body);
                appController.setPetCount(jsonResponse['data']);
              }
            } catch (e) {
              //Utils.noti('Error while updating pet count');
            }
            //Utils.navigateTo(context, const HomeScreen());
          } else {
            print("response.statusCode != 200");
            print(jsonDecode(response.statusCode.toString()));
            Utils.noti("Token expired. Please login again.!!");
            Utils.navigateTo(context, const LoginScreen());
          }
        } else {
          var jsonResponse = jsonDecode(response.body)['message'];

          Utils.noti("Login failed: $jsonResponse");
        }
      } catch (e) {
        print(e);
        // Utils.noti("Something went wrong. Please try again later.");
        Utils.noti("Token expired. Please login again...");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
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
      appBar: const Navbar(
        title: "Pet Spa",
      ),
      drawer: const MaterialDrawer(currentPage: "/home"),
      body: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 64.0),
              ProductCarousel(imgArray: imgArray),
              // Padding(
              //   padding: const EdgeInsets.only(top: 16.0),
              //   child: CardHorizontal(
              //       cta: "Book now",
              //       title: "Pet Spa",
              //       img: "https://via.placeholder.com/200?text=Spa+Booking",
              //       tap: () {
              //         Navigator.pushReplacementNamed(context, '/booking');
              //       }),
              // ),
              const SizedBox(height: 8.0),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     CardSmall(
              //         cta: "View booked history",
              //         title: "Booking History",
              //         img: "https://via.placeholder.com/200?text=History",
              //         tap: () {
              //           Navigator.pushReplacementNamed(context, '/booking_history');
              //         }),
              //     CardSmall(
              //         cta: "Shop now",
              //         title: "Pet Shop",
              //         img: "https://via.placeholder.com/200?text=Pet+Shop",
              //         tap: () {
              //           Navigator.pushReplacementNamed(context, '/');
              //         })
              //   ],
              // ),
              // const SizedBox(height: 8.0),
              // CardHorizontal(
              //     cta: "View article",
              //     title: homeCards["Fashion"]?['title'] ?? "Fashion Title",
              //     img: homeCards["Fashion"]?['image'] ?? "https://via.placeholder.com/200?text=Fashion",
              //     tap: () {
              //       Navigator.pushReplacementNamed(context, '/pro');
              //     }),
              // const SizedBox(height: 8.0),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 32.0),
              //   child: CardSquare(
              //       cta: "View article",
              //       title: homeCards["Argon"]?['title'] ?? "Argon Title",
              //       img: homeCards["Argon"]?['image'] ?? "https://via.placeholder.com/200?text=Argon",
              //       tap: () {
              //         Navigator.pushReplacementNamed(context, '/pro');
              //       }),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
