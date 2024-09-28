import 'package:get/get.dart';

class AppController extends GetxController {
  // Biến phản ứng (Rx) để lưu số lượng tin nhắn chưa đọc và giỏ hàng
  var unreadMessages = 0.obs;
  var cartItems = 0.obs;
  //is authenticated
  var isAuthenticated = false.obs;

  // Hàm để cập nhật số lượng tin nhắn chưa đọc
  void setUnreadMessages(int value) {
    unreadMessages.value = value;
  }

  // Hàm để cập nhật số lượng hàng trong giỏ
  void setCartItems(int value) {
    cartItems.value = value;
  }

  // Hàm để cập nhật trạng thái đăng nhập
  void setIsAuthenticated(bool value) {
    isAuthenticated.value = value;
  }

}
