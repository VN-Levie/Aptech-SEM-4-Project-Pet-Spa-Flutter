import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project/core/app_controller.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/components.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/onboarding.dart';
import 'package:project/screens/pro.dart';
import 'package:project/screens/profile.dart';
import 'package:project/screens/settings.dart';
import 'package:project/screens/spa_booking/booking_history.dart';
import 'package:project/screens/spa_booking/spa_booking.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/register_screen.dart';
import 'screens/shop/pet_shop_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  //biến toàn cục lưu api endpoint
  static const String apiEndpoint = 'http://14.225.203.145:8090';
  static const String apiEndpointLocal = 'http://10.0.2.2:8090';
  
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isFirstTime = false; // Cờ kiểm tra xem có phải lần đầu tiên hay không
  final AppController appController = Get.put(AppController());
  @override
  void initState() {
    super.initState();
    _checkFirstTimeAndAuthentication(); // Kiểm tra xem có phải lần đầu tiên hay không và người dùng đã đăng nhập chưa
  }

  Future<void> _checkFirstTimeAndAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Kiểm tra xem có phải lần đầu tiên mở ứng dụng hay không
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // Nếu là lần đầu tiên mở ứng dụng, lưu lại trạng thái này
    if (isFirstTime) {
      setState(() {
        _isFirstTime = true;
      });
      await prefs.setBool('isFirstTime', false); // Đánh dấu rằng người dùng đã xem Onboarding
    }

    // Cập nhật trạng thái loading
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Hiển thị màn hình chờ trong khi kiểm tra trạng thái
      return const CircularProgressIndicator();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Spa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Kiểm tra xem người dùng có phải lần đầu tiên mở ứng dụng không để hiển thị Onboarding
      // Nếu không phải lần đầu tiên, kiểm tra xem đã đăng nhập hay chưa
      initialRoute: _isFirstTime ? '/onboarding' : '/home',
      routes: {
        '/': (context) => const Home(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const Home(),
        '/register': (context) => const RegisterScreen(),
        '/test_home': (context) => const Home(),
        '/component': (context) => const Components(),
        '/onboarding': (context) => const Onboarding(),
        '/pro': (context) => const Pro(),
        '/profile': (context) => const Profile(),
        '/settings': (context) => const Settings(),
        '/booking': (context) => const SpaBooking(),
        '/booking_history': (context) => const BookingHistoryScreen(),
        '/pet_shop': (context) => const PetShopScreen(),
      },
    );
  }
}
