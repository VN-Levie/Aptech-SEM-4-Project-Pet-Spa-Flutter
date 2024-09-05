import 'package:flutter/material.dart';


class TableCellSettings extends StatelessWidget {
  late String title;
  late void Function()? onTap;
  TableCellSettings({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.black)),
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child:
                  Icon(Icons.arrow_forward_ios, color: Colors.black, size: 14),
            )
          ],
        ),
      ),
    );
  }
}
