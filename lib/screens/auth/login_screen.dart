import 'dart:convert'; // Thêm thư viện này để decode JSON
import 'package:http/http.dart' as http;
import 'package:project/constants/Theme.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/main.dart';
import 'package:project/widgets/input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Thêm Google SignIn

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Username cannot be empty!'),
      ));
      return;
    }
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password must be at least 6 characters!'),
      ));
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
        String token = jsonResponse['data'];

        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Login successfully! Welcome back!'),
        ));
        // Điều hướng đến màn hình chính
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        var jsonResponse = jsonDecode(response.body)['message'];

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonResponse),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          // Hình nền
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/banner.jpg"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Lớp phủ màu trắng mờ
          Container(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
            child: SingleChildScrollView(
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
                  _isLoading // Kiểm tra trạng thái loading
                      ? const Center(child: CircularProgressIndicator()) // Hiển thị vòng tròn loading
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
                    onPressed: _navigateToRegister,
                    child: const Text(
                      'Don\'t have an account? Register here.',
                      style: TextStyle(color: MaterialColors.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: MaterialColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
