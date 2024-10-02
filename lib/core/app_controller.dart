import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/models/account.dart';
import 'package:project/models/shop_product.dart';
import 'package:project/models/cart_item.dart';
import 'package:project/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  // Biến phản ứng (Rx) để lưu số lượng tin nhắn chưa đọc và giỏ hàng
  var unreadMessages = 0.obs;
  var numberOfCartItems = 0.obs;
  //is authenticated
  var isAuthenticated = false.obs;
  var petCount = 0.obs;
  var addressBook = 0.obs;

  var listProduct = [].obs;

  void updateCart(ShopProduct product, {int quantity = 1}) {
    CartItem cartItem = CartItem(
      id: product.id.toString(),
      product: product,
      quantity: quantity,
    );
    //kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
    bool isExist = false;
    for (int i = 0; i < listProduct.length; i++) {
      if (listProduct[i].id == cartItem.id) {
        listProduct[i].quantity += cartItem.quantity;
        isExist = true;
        if (listProduct[i].quantity <= 0) {
          listProduct.removeAt(i);
        }
        break;
      }
    }
    if (!isExist) {
      listProduct.add(cartItem);
    }
    int total = listProduct.length;
    if (numberOfCartItems.value != total) {
      numberOfCartItems.value = total;
    }
    saveCartData();
  }

  void decreaseQuantity(int index, BuildContext context) {
    if (listProduct[index].quantity > 1) {
      listProduct[index].quantity--;
      listProduct.refresh();
    } else {
      
      Utils.confirmDialog(
        context,
        'Remove item',
        'Do you want to remove this item from your cart?',
        () => removeProduct(index),
      );
    }
    int total = listProduct.length;
    if (numberOfCartItems.value != total) {
      numberOfCartItems.value = total;
    }
    saveCartData();
  }

  void removeProduct(int index) {
    
    listProduct.removeAt(index);
    listProduct.refresh();
    int total = listProduct.length;
    if (numberOfCartItems.value != total) {
      numberOfCartItems.value = total;
    }
    saveCartData();
  }

// Hàm tăng số lượng sản phẩm
  void increaseQuantity(int index) {
    listProduct[index].quantity++;
    listProduct.refresh();
    int total = listProduct.length;
    if (numberOfCartItems.value != total) {
      numberOfCartItems.value = total;
    }
    saveCartData();
  }

  void saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItems = listProduct.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList('cart', cartItems);
  }

  void loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartItems = prefs.getStringList('cart');
    if (cartItems != null) {
      listProduct.value = cartItems.map((item) => CartItem.fromJson(json.decode(item))).toList();
    }
    int total = listProduct.length;
    if (numberOfCartItems.value != total) {
      numberOfCartItems.value = total;
    }
  }

  //hàm cập nhật số lượng địa chỉ trong sổ địa chỉ
  void setAddressBook(int value) {
    addressBook.value = value;
  }

  //hàm cập nhật số lượng pet
  void setPetCount(int value) {
    petCount.value = value;
  }

  // Hàm để cập nhật số lượng tin nhắn chưa đọc
  void setUnreadMessages(int value) {
    unreadMessages.value = value;
  }

  // Hàm để cập nhật số lượng hàng trong giỏ
  void setCartItems(int value) {
    numberOfCartItems.value = value;
  }

  //hàm tăng số lượng hàng trong giỏ
  void increaseCartItems() {
    numberOfCartItems.value++;
  }

  // Hàm để cập nhật trạng thái đăng nhập
  void setIsAuthenticated(bool value) {
    isAuthenticated.value = value;
    if (isAuthenticated.value == false) {
      logout();
    }
  }

  Account account = Account(
    id: -1,
    name: 'John Doe',
    email: 'john.doe@example.com',
    roles: "ROLE_USER",
  );

  // Hàm để cập nhật thông tin tài khoản
  void setAccount(Account value) {
    account = value;
  }

  //hàm lấy thông tin tài khoản
  Account getAccount() {
    return account;
  }

  //hàm lấy id tài khoản
  int getAccountId() {
    return account.id;
  }

  //đăng xuất (xóa tất cả thông tin tài khoản)
  void logout() {
    account = Account(
      id: -1,
      name: 'John Doe',
      email: 'john.doe@example.com',
      roles: "ROLE_USER",
    );
    isAuthenticated.value = false;
    //clearCart();
  }
  //clear cart
  void clearCart() {
    listProduct.clear();
    numberOfCartItems.value = 0;
    saveCartData();
  }
}
