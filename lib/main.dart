import 'package:flutter/material.dart';
import 'package:project/screens/components.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/onboarding.dart';
import 'package:project/screens/pro.dart';
import 'package:project/screens/profile.dart';
import 'package:project/screens/settings.dart';
import 'pages/auth/login_screen.dart';
import 'pages/auth/register_screen.dart';  // Thêm dòng này
import 'pages/home/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPA PET',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/onboarding',
      routes: {
        '/': (context) => Home(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(), 
        '/test_home': (context) => Home(),  
        '/component': (context) => Components(),  
        '/onboarding': (context) => Onboarding(),  
        '/pro': (context) => Pro(),  
        '/profile': (context) => Profile(),  
        '/settings': (context) => Settings(),  
      },
    );
  }
}
