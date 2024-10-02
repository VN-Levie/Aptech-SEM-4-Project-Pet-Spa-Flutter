import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // Để gọi API
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/shop_product.dart';
import 'package:project/widgets/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_card.dart';
import 'dart:async';
import 'package:project/widgets/navbar.dart';
import 'package:project/widgets/drawer.dart';
import 'package:project/constants/theme.dart';

class PetShopScreen extends StatefulWidget {
  const PetShopScreen({super.key});

  @override
  _PetShopScreenState createState() => _PetShopScreenState();
}

class _PetShopScreenState extends State<PetShopScreen> {
  final appController = Get.put(AppController());
  int selectedCategory = 0;
  TextEditingController searchController = TextEditingController();

  Timer? _debounce;
  List<Map<String, dynamic>> products = [];
  int productLimit = 10;
  bool isLoadingMore = false;
  bool isLoading = false;
  bool hasMore = true;
  int offset = 0;
  late Map<int, String> categories = {
    0: 'All',
  };

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();

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

  Future<void> _loadCategories() async {
    try {
      String apiCount = '/api/categories';
      var responseCount = await RestService.get(apiCount);
      if (responseCount.statusCode == 200) {
        var jsonResponse = jsonDecode(responseCount.body);
        var data = jsonResponse['data'];

        Map<int, String> categories = {};
        if (data.isNotEmpty) {
          categories[0] = 'All'; // Thêm mục 'All' vào đầu danh sách
          for (var item in data) {
            // Sử dụng id làm khóa và name làm giá trị
            categories[item['id']] = item['name'];
          }

          setState(() {
            this.categories = categories;
          });
        }
      } else {
        Utils.noti("Failed to load categories: ${responseCount.statusCode}");
      }
    } catch (e) {
      Utils.noti('Error while updating categories');
    }
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
    int categoryFilter = selectedCategory != 0 ? selectedCategory : 0;

    String apiUrl = '/api/products/all';

    //lấy loại category
    if (categoryFilter != 0) {
      //api/products?category=1&limit=10&offset=0
      apiUrl = '/api/products?category=$categoryFilter&limit=$productLimit&offset=$offset';
    }

    try {
      var response = await RestService.get(apiUrl);

      if (response.statusCode == 200) {
        // Parse JSON từ phản hồi của API
        var result = jsonDecode(response.body);
        print(result);
        //{status: 200, message: Fetched products successfully, data: [{id: 1, name: Dry Food 1, price: 100.0, imageUrl: https://via.placeholder.com/500?text=Dry Food 1, category: Food}, {id: 2, name: Cat Food 2, price: 110.0, imageUrl: https://via.placeholder.com/500?text=Cat Food 2, category: Food}, {id: 3, name: Cat Food 3, price: 120.0, imageUrl: https://via.placeholder.com/500?text=Cat Food 3, category: Food}, {id: 4, name: Tug Rope 1, price: 100.0, imageUrl: https://via.placeholder.com/500?text=Tug Rope 1, category: Toy}, {id: 5, name: Chew Toy 2, price: 110.0, imageUrl: https://via.placeholder.com/500?text=Chew Toy 2, category: Toy}, {id: 6, name: Tug Rope 3, price: 120.0, imageUrl: https://via.placeholder.com/500?text=Tug Rope 3, category: Toy}, {id: 7, name: Toy Mouse 4, price: 130.0, imageUrl: https://via.placeholder.com/500?text=Toy Mouse 4, category: Toy}, {id: 8, name: Sound Toy 5, price: 140.0, imageUrl: https://via.placeholder.com/500?text=Sound Toy 5, category: Toy},
        if (result.isNotEmpty) {
          var data = result['data'];
          if (data.isNotEmpty) {
            setState(() {
              products.addAll(List<Map<String, dynamic>>.from(data));
              offset += productLimit;
            });
          } else {
            setState(() {
              hasMore = false;
            });
            _showNoMoreProductsMessage();
          }
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
      drawer: const MaterialDrawer(currentPage: "/pet_shop"),
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
                  child: DropdownButton<int>(
                    value: selectedCategory, // Sử dụng int (key) làm giá trị
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                        _refreshProducts();
                      });
                    },
                    items: categories.entries.map<DropdownMenuItem<int>>((MapEntry<int, String> entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key, // Sử dụng int (key) làm giá trị
                        child: Text(entry.value), // Hiển thị String (value) trong Text
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75),
                    itemCount: products.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final product = products[index];
                      ShopProduct shopProduct = ShopProduct(
                        id: product['id'].toString(),
                        name: product['name'],
                        price: product['price'],
                        imageUrl: product['imageUrl'],
                        description: product['description'] ?? '',
                      );
                      return ProductCard(
                        shopProduct: shopProduct,
                        onAddToCart: () {
                         appController.updateCart(shopProduct);
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
