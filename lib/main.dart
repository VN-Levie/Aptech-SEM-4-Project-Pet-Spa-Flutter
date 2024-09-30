import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/components.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/onboarding_screen.dart';
import 'package:project/screens/pro.dart';
import 'package:project/screens/profile.dart';
import 'package:project/screens/settings.dart';
import 'package:project/screens/spa_booking/booking_history.dart';
import 'package:project/screens/spa_booking/spa_booking.dart';



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

}

class _MyAppState extends State<MyApp> {
  final AppController appController = Get.put(AppController());
  @override
  void initState() {
    super.initState();   
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Spa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Kiểm tra xem người dùng có phải lần đầu tiên mở ứng dụng không để hiển thị Onboarding
      // Nếu không phải lần đầu tiên, kiểm tra xem đã đăng nhập hay chưa
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/component': (context) => const Components(),
        '/onboarding': (context) => const OnboardingScreen(),
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
