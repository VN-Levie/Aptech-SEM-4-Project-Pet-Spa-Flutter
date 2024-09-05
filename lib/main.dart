import 'package:flutter/material.dart';
import 'package:project/screens/components.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/onboarding.dart';
import 'package:project/screens/pro.dart';
import 'package:project/screens/profile.dart';
import 'package:project/screens/settings.dart';
import 'package:project/screens/spa_booking/booking_history.dart';
import 'package:project/screens/spa_booking/spa_booking.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart'; // Thêm dòng này

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPA PET',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/onboarding',
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
        '/booking': (context) => SpaBooking(),
        '/booking_history': (context) => const BookingHistoryScreen(),
      },
    );
  }
}
