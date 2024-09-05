import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../constants/Theme.dart';
import '../../widgets/input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _databaseHelper = DatabaseHelper();

  void _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final existingUser = await _databaseHelper.getUser(username, password);
    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User already exists! Please choose a different username.'),
      ));
      return;
    }

    await _databaseHelper.insertUser(username, password);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Registration successful! You can now log in.'),
    ));
    Navigator.pop(context);
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: MaterialColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              backgroundImage: Image.asset("assets/img/logo.jpg").image,
              radius: 100.0,
            ),
            const SizedBox(height: 20),
            Input(
              placeholder: "Username",
              controller: _usernameController,
            ),
            const SizedBox(height: 10),
            Input(
              placeholder: "Password",
              controller: _passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MaterialColors.primary,
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
            const Spacer(), // Đẩy nút "Back to Home" xuống dưới cùng
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
    );
  }
}
