import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/core/rest_service.dart';
import 'package:project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/Theme.dart';
import '../../widgets/input.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Thêm Google SignIn

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Khởi tạo GoogleSignIn
  bool _isLoading = false; // Biến trạng thái để theo dõi quá trình loading

  Future<void> _register() async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    // Kiểm tra tính hợp lệ của dữ liệu nhập
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Username cannot be empty!'),
      ));
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
      return;
    }
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password must be at least 6 characters!'),
      ));
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
      return;
    }

    // Gọi API đăng ký người dùng
    try {
      // var response = await RestService.post('/auth/login', {
      //   'username': username,
      //   'password': password,
      // });

      // var response = await http.post(
      //   Uri.parse('${MyApp.apiEndpointLocal}/api/auth/register'),
      //   headers: <String, String>{
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode(<String, String>{
      //     'username': username,
      //     'password': password,
      //     'rePassword': password, // Để đơn giản hóa, rePassword là password
      //   }),
      // );
  FocusScope.of(context).unfocus();
      var response = await RestService.post('/api/auth/register', {
        'username': username,
        'password': password,
        'rePassword': password, // Để đơn giản hóa, rePassword là password
      });

      if (response.statusCode == 201) {
        // Đăng ký thành công và nhận JWT token
        var jsonResponse = jsonDecode(response.body);
        String token = jsonResponse['data']; // JWT token

        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        // Điều hướng đến màn hình chính sau khi đăng ký thành công
        Navigator.pushReplacementNamed(context, '/home');
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonResponse['message']),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to register! Please try again.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
    }
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
                          onPressed: _register,
                          child: const Text(
                            'Register',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _navigateToLogin,
                    child: const Text(
                      'Already have an account? Login here.',
                      style: TextStyle(color: MaterialColors.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _navigateToHome,
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

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
