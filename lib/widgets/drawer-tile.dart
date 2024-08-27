import 'package:flutter/material.dart';

import 'package:pet_spa/constants/Theme.dart';

class DrawerTile extends StatelessWidget {
  late String? title;
  late IconData? icon;
  late void Function()? onTap;
  late bool isSelected;
  late Color iconColor;

  DrawerTile(
      {this.title,
      this.icon,
      this.onTap,
      this.isSelected = false,
      this.iconColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            height: 45,
            padding: EdgeInsets.symmetric(horizontal: 16),
            margin: EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
                color: isSelected ? MaterialColors.active : Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(4))),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Icon(icon,
                      size: 20, color: isSelected ? Colors.white : iconColor),
                ),
                Text(title!,
                    style: TextStyle(
                        fontSize: 15,
                        color: isSelected ? Colors.white : Colors.black))
              ],
            )));
  }
}
