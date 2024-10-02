import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/models/cart_item.dart';
import 'package:project/models/shop_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {

  static Future<T> navigateTo<T>(BuildContext context, Widget screen, {bool clearStack = false}) {
    if (clearStack) {
      return Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
        (Route<dynamic> route) => false, // Xóa sạch tất cả các route trước đó
      ) as Future<T>;
    } else {
      return Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ) as Future<T>;
    }
  }

  static void noti(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.SNACKBAR, backgroundColor: MaterialColors.primary, textColor: const Color.fromRGBO(109, 74, 74, 1), fontSize: 16.0, webShowClose: true);
  }

  //hộp thoại hỏi ng dùng có muốn đăng nhập không
  static void confirmDialogz(BuildContext context, String title, String content, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void confirmDialog(BuildContext context, String title, String content, Function onConfirm, {String? confirmText = "OK", String? cancelText = "Cancel"}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Bo góc cho hộp thoại
          ),
          backgroundColor: MaterialColors.bgColorScreen, // Nền hộp thoại từ MaterialColors
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/img/logo.jpg'), // Thêm logo nhỏ
                radius: 20, // Điều chỉnh kích thước logo
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MaterialColors.primary, // Màu tiêu đề từ MaterialColors
                ),
              ),
            ],
          ),
          content: Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: MaterialColors.caption, // Màu nội dung từ MaterialColors
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                cancelText ?? "Cancel", // Nếu không có cancelText thì sẽ hiển thị Cancel
                style: TextStyle(color: MaterialColors.error), // Màu nút Cancel từ MaterialColors
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MaterialColors.primary, // Màu nền nút OK từ MaterialColors
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Bo góc nút OK
                ),
              ),
              child: Text(
                confirmText ?? "OK", // Nếu không có confirmText thì sẽ hiển thị OK
                style: TextStyle(color: MaterialColors.textButton), // Màu chữ nút OK
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại trước khi thực hiện hành động
                onConfirm(); // Thực hiện hành động được truyền vào
              },
            ),
          ],
        );
      },
    );
  }

  static String replaceLocalhost(String url) {
    return url.replaceFirst('localhost', '10.0.2.2');
  }


}
