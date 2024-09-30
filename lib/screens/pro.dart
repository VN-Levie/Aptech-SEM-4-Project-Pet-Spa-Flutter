import 'package:flutter/material.dart';

import 'package:project/constants/theme.dart';

class Pro extends StatelessWidget {
  const Pro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/img/onboard-background.jpg"), fit: BoxFit.cover))),
      Padding(
        padding: const EdgeInsets.only(top: 73, left: 32, right: 32, bottom: 16),
        child: Container(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: Text.rich(TextSpan(text: "Material Kit", style: const TextStyle(color: Colors.white, fontSize: 58), children: <InlineSpan>[
                        WidgetSpan(
                            child: Container(
                                padding: const EdgeInsets.all(2.0),
                                margin: const EdgeInsets.fromLTRB(10.0, 0.0, 50.0, 50.0),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), color: MaterialColors.label),
                                child: const Padding(
                                  padding: EdgeInsets.only(top: 0, bottom: 0, left: 4, right: 4),
                                  child: Text("PRO",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      )),
                                ))),
                      ])),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Text("Take advantage of all the features and screens made by Creative Tim, coded on Flutter for both.", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w200)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 42.0),
                  child: Row(children: <Widget>[
                    Image.asset("assets/img/logo-ios.png", scale: 2.6),
                    const SizedBox(width: 30.0),
                    Image.asset("assets/img/logo-android.png", scale: 2.6)
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white, // Màu chữ
                        backgroundColor: MaterialColors.info, // Màu nền
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12, bottom: 12),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
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
                )
              ],
            ),
          ),
        ),
      )
    ]));
  }
}
