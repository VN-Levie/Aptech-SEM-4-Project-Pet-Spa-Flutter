import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';

class RegisterScreen extends StatefulWidget {
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

    // Kiểm tra nếu người dùng đã tồn tại
    final existingUser = await _databaseHelper.getUser(username, password);
    if (existingUser != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User already exists! Please choose a different username.'),
      ));
      return;
    }

    // Thêm người dùng mới vào cơ sở dữ liệu
    await _databaseHelper.insertUser(username, password);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Registration successful! You can now log in.'),
    ));

    // Chuyển hướng về màn hình đăng nhập
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
