import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/widgets/utils.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _logout();
  }

  Future<void> _logout() async {
    try {
      // Xóa token và refresh token từ secure storage
      await _storage.delete(key: 'jwt_token');
      await _storage.delete(key: 'refresh_token');

      // Xóa thông tin tài khoản và isFirstTime từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('account');
      await prefs.remove('first_time');
      final AppController appController = Get.put(AppController());
      appController.setIsAuthenticated(false);
      // Hiển thị thông báo đăng xuất thành công
      Utils.noti("Hope to see you again soon!");
    } catch (e) {
      print(e);
      // Utils.noti("An error occurred while logging out. Please try again.");
    } finally {
      // Điều hướng đến màn hình onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Hiển thị khi đang xử lý đăng xuất
      ),
    );
  }
}
