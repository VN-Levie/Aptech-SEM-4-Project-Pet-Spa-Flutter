import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/auth/login_screen.dart';
import 'package:project/widgets/drawer.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? lastPressed; // Biến lưu trữ thời gian lần nhấn back gần nhất

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        const exitWarningDuration = Duration(seconds: 2);

        if (lastPressed == null || now.difference(lastPressed!) > exitWarningDuration) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit the app'),
              duration: exitWarningDuration,
            ),
          );
          return false; // Không thoát, chờ lần nhấn tiếp theo
        }
        lastPressed = null;
        return true; // Thoát ứng dụng
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        drawer: const MaterialDrawer(currentPage: "Home"),
        body: const Center(
          child: Text('Welcome to the SPA PET app!'),
        ),
      ),
    );
  }
}
