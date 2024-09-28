import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Để gọi API
import 'package:shared_preferences/shared_preferences.dart';
import 'product_card.dart';
import 'dart:async';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/Theme.dart';

class PetShopScreen extends StatefulWidget {
  const PetShopScreen({super.key});

  @override
  _PetShopScreenState createState() => _PetShopScreenState();
}

class _PetShopScreenState extends State<PetShopScreen> {
  String selectedCategory = 'Tất cả';
  TextEditingController searchController = TextEditingController();
  int cartCount = 0;
  Timer? _debounce;
  List<Map<String, dynamic>> products = [];
  int productLimit = 10;
  bool isLoadingMore = false;
  bool isLoading = false;
  bool hasMore = true;
  int offset = 0;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCartCount();
    _loadProductsFromAPI(); // Gọi API thay vì từ cơ sở dữ liệu
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCartCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      cartCount = prefs.getInt('cart_count') ?? 0;
    });
  }

  Future<void> _updateCartCount(int count) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cart_count', count);
    setState(() {
      cartCount = count;
    });
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    // Logic thêm sản phẩm vào giỏ hàng
    // Cập nhật giỏ hàng và show snackbar
    int currentCartCount = cartCount + 1;
    await _updateCartCount(currentCartCount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sản phẩm đã được thêm vào giỏ hàng')),
    );
  }

  Future<void> _loadProductsFromAPI({bool isRefresh = false}) async {
    setState(() {
      isLoading = true;
    });

    if (isRefresh) {
      offset = 0;
      products.clear();
      hasMore = true;
    }

    String searchText = searchController.text;
    String categoryFilter = selectedCategory != 'Tất cả' ? selectedCategory : '';
    
    // URL API để lấy sản phẩm (thay localhost bằng 10.0.2.2 để tránh lỗi trên emulator)
    final String apiUrl = 'http://10.0.2.2:8090/api/products?limit=$productLimit&offset=$offset&search=$searchText&category=$categoryFilter';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse JSON từ phản hồi của API
        List<dynamic> result = jsonDecode(response.body);

        if (result.isNotEmpty) {
          setState(() {
            products.addAll(List<Map<String, dynamic>>.from(result));
            offset += productLimit;
          });
        } else {
          setState(() {
            hasMore = false;
          });
          _showNoMoreProductsMessage();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _onSearchSubmitted(String? value) {
    setState(() {
      isLoading = true;
    });
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      await _loadProductsFromAPI(isRefresh: true);
    }
  }

  void _clearSearch() {
    searchController.clear();
    _refreshProducts();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (hasMore && !isLoadingMore) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (hasMore && !isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });
      await _loadProductsFromAPI();
    }
  }

  void _showNoMoreProductsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã hết sản phẩm để tải thêm!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        backButton: false,
        title: 'Pet Shop',
        searchBar: true,
        searchController: searchController,
        searchOnSubmitted: _onSearchSubmitted,
      ),
      backgroundColor: MaterialColors.bgColorScreen,
      drawer: const MaterialDrawer(currentPage: "pet_shop"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                        _refreshProducts();
                      });
                    },
                    items: <String>[
                      'Tất cả',
                      'Thức ăn',
                      'Đồ chơi',
                      'Phụ kiện',
                      'Quần áo',
                      'Vòng cổ',
                      'Dây dẫn'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshProducts,
                  child: GridView.builder(
                    controller: _scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.75),
                    itemCount: products.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final product = products[index];
                      return ProductCard(
                        sellerImage: 'https://i.pravatar.cc/150?img=1',
                        sellerName: 'test',
                        name: product['name'],
                        price: product['price'],
                        imageUrl: product['imageUrl'],
                        onAddToCart: () {
                          _addToCart(product);
                        },
                      );
                    },
                  ),
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
