import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

import 'package:project/constants/Theme.dart';

import 'package:project/widgets/drawer-tile.dart';

class MaterialDrawer extends StatelessWidget {
  final String currentPage;

  const MaterialDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
          child: Column(children: [
        DrawerHeader(
            decoration: const BoxDecoration(color: MaterialColors.drawerHeader),
            child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  // backgroundImage: NetworkImage("https://i.imgur.com/mD2jD2w.jpeg"),
                  backgroundImage: Image.asset("assets/img/logo.jpg").image,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0, top: 16.0),
                  child: Text("Pet Spa", style: TextStyle(color: Colors.white, fontSize: 21)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MaterialColors.label), child: const Text("Pro", style: TextStyle(color: Colors.white, fontSize: 16))),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Text("Seller", style: TextStyle(color: MaterialColors.muted, fontSize: 16)),
                      ),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text("999", style: TextStyle(color: MaterialColors.warning, fontSize: 16)),
                          ),
                          Icon(Icons.star_border, color: MaterialColors.warning, size: 20)
                        ],
                      )
                    ],
                  ),
                )
              ],
            ))),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          children: [
            DrawerTile(
                icon: Icons.home,
                onTap: () {
                  if (currentPage != "Home") Navigator.pushReplacementNamed(context, '/home');
                },
                iconColor: Colors.black,
                title: "Home",
                isSelected: currentPage == "Home" ? true : false),
            DrawerTile(
                icon: Icons.calendar_month,
                onTap: () {
                  if (currentPage != "Components") Navigator.pushReplacementNamed(context, '/component');
                },
                iconColor: Colors.black,
                title: "Spa Booking",
                isSelected: currentPage == "Components" ? true : false),
            DrawerTile(
                icon: Icons.shopping_cart,
                onTap: () {
                  if (currentPage != "Components") Navigator.pushReplacementNamed(context, '/component');
                },
                iconColor: Colors.black,
                title: "Pet Shop",
                isSelected: currentPage == "Components" ? true : false),
            DrawerTile(
                icon: Icons.hotel,
                onTap: () {
                  if (currentPage != "Components") Navigator.pushReplacementNamed(context, '/component');
                },
                iconColor: Colors.black,
                title: "Pet Hotel",
                isSelected: currentPage == "Components" ? true : false),
            DrawerTile(
                icon: Icons.dashboard_customize,
                onTap: () {
                  if (currentPage != "Components") Navigator.pushReplacementNamed(context, '/component');
                },
                iconColor: Colors.black,
                title: "Accessories Customization",
                isSelected: currentPage == "Components" ? true : false),
            DrawerTile(
                icon: Icons.account_circle,
                onTap: () {
                  if (currentPage != "Profile") Navigator.pushReplacementNamed(context, '/profile');
                },
                iconColor: Colors.black,
                title: "Profile",
                isSelected: currentPage == "Profile" ? true : false),
            DrawerTile(
                icon: Icons.settings,
                onTap: () {
                  if (currentPage != "Settings") Navigator.pushReplacementNamed(context, '/settings');
                },
                iconColor: Colors.black,
                title: "App Settings",
                isSelected: currentPage == "Settings" ? true : false),
            DrawerTile(
                icon: Icons.settings,
                onTap: () {
                  if (currentPage != "Settings") Navigator.pushReplacementNamed(context, '/onboarding');
                },
                iconColor: Colors.black,
                title: "onboarding",
                isSelected: currentPage == "Settings" ? true : false),
            DrawerTile(
                icon: Icons.exit_to_app,
                onTap: () {
                  //if (currentPage != "Sign In") Navigator.pushReplacementNamed(context, '/signin');
                },
                iconColor: Colors.black,
                title: "Sign In",
                isSelected: currentPage == "Sign In" ? true : false),
            DrawerTile(
                icon: Icons.open_in_browser,
                onTap: () {
                  //if (currentPage != "Sign Up") Navigator.pushReplacementNamed(context, '/signup');
                },
                iconColor: Colors.black,
                title: "Sign Up",
                isSelected: currentPage == "Sign Up" ? true : false),
          ],
        ))
      ])),
    );
  }
}
