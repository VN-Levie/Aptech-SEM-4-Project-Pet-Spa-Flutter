import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project/screens/shop/product_details.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final VoidCallback onAddToCart;
  final String imageUrl;
  final String sellerName; // Thêm thông tin người bán
  final String sellerImage; // Thêm ảnh người bán

  const ProductCard({super.key, 
    required this.name,
    required this.price,
    required this.onAddToCart,
    required this.imageUrl,
    required this.sellerName, // Nhận thông tin người bán
    required this.sellerImage, // Nhận ảnh người bán
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Chuyển sang trang chi tiết sản phẩm khi nhấn vào
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              productName: name,
              price: price,
              productImages: [imageUrl, 'https://via.placeholder.com/500?text=Product+Image+2'],             
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: SizedBox.expand(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image,
                          size: 50, color: Colors.grey),
                    ),
                    fit: BoxFit.cover, // Đảm bảo ảnh lấp đầy không gian và giữ tỷ lệ
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name, style: const TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('\$ $price',
                  style: const TextStyle(fontSize: 14, color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: onAddToCart,
              child: const Text('Thêm vào giỏ'),
            ),
          ],
        ),
      ),
    );
  }
}
