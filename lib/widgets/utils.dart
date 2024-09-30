import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/constants/theme.dart';

class Utils {
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
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
    );
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
}
