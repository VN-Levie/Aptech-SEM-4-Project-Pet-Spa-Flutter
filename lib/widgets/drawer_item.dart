import 'package:flutter/material.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/widgets/drawer-tile.dart';
import 'package:project/widgets/utils.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentPage;
  final BuildContext context;
  final Widget screen;
  final bool needLogin;
  
  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.currentPage,
    required this.context,
    required this.screen,
    required this.needLogin,
  });
  
  @override
  Widget build(BuildContext context) {
    
    final bool isSelected = currentPage == route;

    return DrawerTile(
      icon: icon,
      onTap: () {
        if (needLogin) {
          Utils.confirmDialog(context, "Login Required", "This feature needs a logged-in account.", () {
            Utils.navigateTo(context, const LoginScreen());
          }, confirmText: "Login Now", cancelText: "Not Now");
        } else if (!isSelected) {
          Utils.navigateTo(context, screen);
        }
      },
      iconColor: Colors.black,
      title: title,
      isSelected: isSelected,
    );
  }
}
