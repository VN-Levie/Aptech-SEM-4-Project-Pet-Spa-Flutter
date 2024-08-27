import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
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
            SnackBar(
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
          title: Text('Home'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  // Navigate to the Home screen
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: Icon(Icons.pets),
                title: Text('Pet Shop'),
                onTap: () {
                  // Navigate to the Pet Shop screen (to be implemented)
                },
              ),
              ListTile(
                leading: Icon(Icons.hotel),
                title: Text('Pet Hotel'),
                onTap: () {
                  // Navigate to the Pet Hotel screen (to be implemented)
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
                onTap: () {
                  // Navigate to the Profile screen (to be implemented)
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Test'),
                onTap: () {
                  // Navigate to the Profile screen (to be implemented)
                  Navigator.pushReplacementNamed(context, '/test');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('component'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/component');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('onboarding'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/onboarding');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('pro'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/pro');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('profile'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('settings'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/settings');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: Center(
          child: Text('Welcome to the SPA PET app!'),
        ),
      ),
    );
  }
}
