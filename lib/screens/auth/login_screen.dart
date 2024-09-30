import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/auth/register_screen.dart';
import 'package:project/screens/home.dart';
import 'package:project/widgets/input.dart';
import 'package:project/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Biến trạng thái để theo dõi quá trình loading

  // Hàm đăng nhập bằng tài khoản
  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    //check nukl
    if (username.isEmpty) {
      Utils.noti("Please enter your email!");
      return;
    }
    if (password.isEmpty) {
      Utils.noti("Please enter your password!");
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(username)) {
      Utils.noti("Invalid email format!");
      return;
    }

    setState(() {
      _isLoading = true; // Bắt đầu loading
    });
    //ẩn bàn phím
    FocusScope.of(context).unfocus();
    try {
      var response = await RestService.post('/api/auth/login', {
        'email': username,
        'password': password,
      });
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var authData = jsonResponse['data'];

        // Trích xuất JWT từ AuthData
        String token = authData['jwt'];
        String refreshToken = authData['refreshToken'];
        var account = authData['account'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        //lưu thông tin tài khoản
        await prefs.setString('account', jsonEncode(account));

        //lưu token và refresh token vào secure storage
        FlutterSecureStorage storage = FlutterSecureStorage();
        await storage.write(key: 'jwt_token', value: token);
        await storage.write(key: 'refresh_token', value: refreshToken);
        final AppController appController = Get.put(AppController());
        appController.setIsAuthenticated(true);
        Utils.noti("Login successfully! Welcome back!");
        Utils.navigateTo(context, const HomeScreen());
      } else {
        var jsonResponse = jsonDecode(response.body)['message'];

        Utils.noti("Login failed: $jsonResponse");
      }
    } catch (e) {
      if (e is SocketException) {
        Utils.noti("Network error. Please check your connection.");
      } else {
        Utils.noti("Something went wrong. Please try again later.");
      }
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            // Hình nền
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/img/banner.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Lớp phủ màu đen mờ
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black54.withOpacity(0.65), // Đặt độ mờ cho lớp phủ
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: MaterialColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  CircleAvatar(
                    backgroundImage: Image.asset("assets/img/logo.jpg").image,
                    radius: 80.0,
                  ),
                  const SizedBox(height: 20),
                  Input(
                    placeholder: "Username",
                    controller: _usernameController,
                    textColor: MaterialColors.input,
                  ),
                  const SizedBox(height: 10),
                  Input(
                    placeholder: "Password",
                    controller: _passwordController,
                    isPassword: true,
                    textColor: MaterialColors.input,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: MaterialColors.active,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Utils.navigateTo(context, const RegisterScreen());
                    },
                    child: const Text(
                      'Don\'t have an account? Register here.',
                      style: TextStyle(color: MaterialColors.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Utils.navigateTo(context, const HomeScreen());
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: MaterialColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
