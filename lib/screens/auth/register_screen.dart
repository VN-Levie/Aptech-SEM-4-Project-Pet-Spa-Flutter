import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/home.dart';
import 'package:project/widgets/input.dart';
import 'package:project/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String rePassword = _rePasswordController.text;

    if (name.isEmpty) {
      Utils.noti("Please enter your name!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (email.isEmpty) {
      Utils.noti("Email cannot be empty!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      Utils.noti("Invalid email format!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty || password.length < 6) {
      Utils.noti("Password must be at least 6 characters!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password != rePassword) {
      Utils.noti("Passwords do not match!");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      FocusScope.of(context).unfocus();

      // Gửi yêu cầu POST tới endpoint '/api/auth/register'
      var response = await RestService.post('/api/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'rePassword': rePassword,
      });

      // Kiểm tra mã trạng thái phản hồi
      if (response.statusCode == 201) {
        // Giải mã phản hồi JSON
        var jsonResponse = jsonDecode(response.body);

        // Kiểm tra xem 'data' có chứa đối tượng AuthData không
        if (jsonResponse.containsKey('data')) {
          var authData = jsonResponse['data'];

          // Trích xuất JWT từ AuthData
          String token = authData['jwt'];
          String refreshToken = authData['refreshToken'];
          var account = authData['account'];

          // Lưu tài khoản vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('account', jsonEncode(account));

          //lưu token và refresh token vào secure storage
          FlutterSecureStorage storage = FlutterSecureStorage();
          await storage.write(key: 'jwt_token', value: token);
          await storage.write(key: 'refresh_token', value: refreshToken);
          final AppController appController = Get.put(AppController());
          appController.setIsAuthenticated(true);
          // Hiển thị thông báo thành công và điều hướng tới HomeScreen
          Utils.noti("Register successfully! Welcome to Pet Spa!");
          Utils.navigateTo(context, const HomeScreen());
        } else {
          Utils.noti("Registration failed: No token received.");
        }
      } else if (response.statusCode == 400) {
        // Xử lý lỗi 400: Dữ liệu không hợp lệ
        var jsonResponse = jsonDecode(response.body);
        Utils.noti(jsonResponse['message'] ?? 'Invalid input data');
      } else {
        // Xử lý các mã trạng thái khác
        var jsonResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${response.statusCode}: ${jsonResponse['message'] ?? 'Unknown error'}'),
          ),
        );
      }
    } catch (e) {
      // Bắt lỗi ngoại lệ
      if (e is SocketException) {
        Utils.noti("Network error. Please check your connection.");
      } else {
        Utils.noti("Something went wrong. Please try again later.");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    return email.isNotEmpty && emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/img/banner.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black54.withOpacity(0.65),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Welcome to Pet Spa!",
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
                    placeholder: "Name",
                    controller: _nameController,
                    textColor: MaterialColors.input,
                  ),
                  const SizedBox(height: 10),
                  Input(
                    placeholder: "Email",
                    controller: _emailController,
                    textColor: MaterialColors.input,
                  ),
                  const SizedBox(height: 10),
                  Input(
                    placeholder: "Password",
                    controller: _passwordController,
                    isPassword: true,
                    textColor: MaterialColors.input,
                  ),
                  const SizedBox(height: 10),
                  Input(
                    placeholder: "Re-enter Password",
                    controller: _rePasswordController,
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
                          onPressed: _register,
                          child: const Text(
                            'Register',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Utils.navigateTo(context, const LoginScreen());
                    },
                    child: const Text(
                      'Already have an account? Login here.',
                      style: TextStyle(color: MaterialColors.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
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
