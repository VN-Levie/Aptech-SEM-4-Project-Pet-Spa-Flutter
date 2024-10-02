import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/shop/checkout_screen.dart';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/utils.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({
    super.key,
  });

  @override
  _ShoppingCartPage createState() => _ShoppingCartPage();
}

class _ShoppingCartPage extends State<ShoppingCartPage> {
  final AppController appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: 'Shopping Cart',
        backButton: true,
        rightOptions: false,
      ),
      body: Column(
        children: [
          Obx(() {
            double total = appController.listProduct.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Cart subtotal (${appController.listProduct.length} items): \$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: appController.listProduct.length,
                itemBuilder: (context, index) {
                  final item = appController.listProduct[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh sản phẩm với caching và loading
                          Container(
                            width: 140,
                            height: 140,
                            child: CachedNetworkImage(
                              imageUrl: item.product.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                          // Thông tin sản phẩm
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'In Stock',
                                    style: TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '\$${item.product.price}',
                                    style: TextStyle(
                                      color: MaterialColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Nút tăng/giảm số lượng
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              appController.decreaseQuantity(index, context);
                                            },
                                          ),
                                          Text('${item.quantity}'),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              appController.increaseQuantity(index);
                                            },
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Utils.confirmDialog(
                                            context,
                                            'Remove item',
                                            'Do you want to remove this item from your cart?',
                                            () => appController.removeProduct(index),
                                          );
                                        },
                                        child: Text('DELETE'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (!appController.isAuthenticated.value) {
                  Utils.confirmDialog(context, "Login Required", "This feature needs a logged-in account.", () {
                    Utils.navigateTo(context, const LoginScreen());
                  }, confirmText: "Login Now", cancelText: "Not Now");
                  return;
                }
                 Utils.navigateTo(context, const CheckoutScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MaterialColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text('PROCEED TO CHECKOUT', style: TextStyle(color: MaterialColors.caption, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
