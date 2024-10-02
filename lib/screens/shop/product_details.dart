import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/models/shop_product.dart';
import 'dart:async';
import 'package:project/widgets/navbar.dart';

class ProductCarousel extends StatefulWidget {
  final List<Map<String, String>> imgArray;

  const ProductCarousel({
    super.key,
    required this.imgArray,
  });

  @override
  _ProductCarouselState createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  int _current = 0; // Để lưu trạng thái của trang hiện tại
  bool _autoPlay = true; // Tình trạng tự động phát
  Timer? _autoPlayTimer; // Bộ đếm thời gian để theo dõi sau khi người dùng tương tác

  @override
  void dispose() {
    _autoPlayTimer?.cancel(); // Hủy bộ đếm khi widget bị hủy
    super.dispose();
  }

  void _startAutoPlayTimer() {
    _autoPlayTimer?.cancel(); // Hủy bỏ bất kỳ Timer nào trước đó
    setState(() {
      _autoPlay = false; // Tạm dừng tự động play khi người dùng tương tác
    });

    _autoPlayTimer = Timer(const Duration(seconds: 5), () {
      // Sau 5 giây, nếu không có tương tác, bật lại tự động play
      setState(() {
        _autoPlay = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          items: widget.imgArray.map((item) {
            return Container(
              child: ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: item["img"] ?? "",
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 400,
            viewportFraction: 1.0,
            autoPlay: _autoPlay, // Tùy vào trạng thái autoPlay
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });

              // Khi người dùng chủ động lướt ảnh
              if (reason == CarouselPageChangedReason.manual) {
                _startAutoPlayTimer(); // Tạm dừng autoplay và khởi động bộ đếm 5 giây
              }
            },
          ),
        ),
        Positioned(
          bottom: 10, // Cách đáy ảnh 10px
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imgArray.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => setState(() {
                  _current = entry.key;
                }),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(_current == entry.key ? 0.9 : 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ProductDetails extends StatefulWidget {
  final ShopProduct product;

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final appController = Get.put(AppController());

  int quantity = 1; // Biến lưu số lượng sản phẩm
  Future<void> addToCart(ShopProduct product) async {
    appController.updateCart(product, quantity: quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Navbar(
        title: widget.product.name,
        transparent: true,
        backButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProductCarousel(
              imgArray: widget.product.imageUrls
                  .map((img) => {
                        "img": img
                      })
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\$${widget.product.price.toString()}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Quantity",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      addToCart(widget.product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "ADD TO CART",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
