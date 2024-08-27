import 'package:flutter/material.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterScreen(),  // Định nghĩa route cho màn hình đăng ký
      },
    );
  }
}
