import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project/models/cart_item.dart';
import 'package:project/models/shop_product.dart';
import 'package:project/screens/shop/product_details.dart';
import 'package:project/widgets/utils.dart';

class ProductCard extends StatelessWidget {
  final ShopProduct shopProduct;
    final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.shopProduct,   
    required this.onAddToCart, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Chuyển sang trang chi tiết sản phẩm khi nhấn vào
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(product: shopProduct),            
            
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
                    imageUrl: Utils.replaceLocalhost(shopProduct.imageUrl),
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                    fit: BoxFit.cover, // Đảm bảo ảnh lấp đầy không gian và giữ tỷ lệ
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(shopProduct.name, style: const TextStyle(fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('\$ ${shopProduct.price}', style: const TextStyle(fontSize: 14, color: Colors.green)),
            ),
            ElevatedButton(
              onPressed: onAddToCart,
              child: const Text('Add to cart'),
            ),
          ],
        ),
      ),
    );
  }
}
