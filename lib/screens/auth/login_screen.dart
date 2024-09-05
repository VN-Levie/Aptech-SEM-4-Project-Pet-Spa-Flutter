import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import 'register_screen.dart';
import '../../constants/Theme.dart'; // Import Theme constants
import '../../widgets/input.dart'; // Sử dụng widget tùy chỉnh cho Input

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseHelper = DatabaseHelper();

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final user = await _databaseHelper.getUser(username, password);

    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid username or password'),
      ));
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacementNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                ElevatedButton(
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
                //const Spacer(), // Đẩy nút "Back to Home" xuống dưới cùng
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
        ],
      ),
    );
  }
}
