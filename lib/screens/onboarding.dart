import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/constants/Theme.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  Future<void> _setFirstTimeFalse(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false); // Đặt cờ isFirstTime thành false
    Navigator.pushReplacementNamed(context, '/home'); // Chuyển hướng đến màn hình Home
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
            padding: const EdgeInsets.only(top: 50, left: 32, right: 32, bottom: 16),
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Đặt nội dung chính giữa màn hình
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "Pet Spa",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 58,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2.0, 2.0),
                                  blurRadius: 4.0,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        CircleAvatar(
                          backgroundImage: Image.asset("assets/img/logo.jpg").image,
                          radius: 100.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Text(
                            "Love and care from head to tail!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: const Offset(1.2, 1.2),
                                  blurRadius: 2,
                                  color: Colors.black.withOpacity(1),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "©2024. T1.2210.E0 - G1, made with ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1.2, 1.2),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(1),
                                      ),
                                    ],
                                  ),
                                ),
                                const WidgetSpan(
                                  child: Icon(
                                    Icons.favorite, // Biểu tượng trái tim
                                    color: Colors.red,
                                    size: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: " & ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1.2, 1.2),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(1),
                                      ),
                                    ],
                                  ),
                                ),
                                const WidgetSpan(
                                  child: Icon(
                                    Icons.local_cafe, // Biểu tượng cốc cà phê
                                    color: Colors.brown,
                                    size: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: ".",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1.2, 1.2),
                                        blurRadius: 2,
                                        color: Colors.black.withOpacity(1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: MaterialColors.active,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 12,
                            bottom: 12,
                          ),
                        ),
                        onPressed: () {
                          _setFirstTimeFalse(context); // Đặt cờ isFirstTime và chuyển hướng
                        },
                        child: const Text(
                          "GET STARTED",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
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
