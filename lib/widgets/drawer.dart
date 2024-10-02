import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/auth/logout_screen.dart';
import 'package:project/screens/auth/register_screen.dart';
import 'package:project/screens/components.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/pet_hotel/rent_pet_hotel.dart';
import 'package:project/screens/profile.dart';
import 'package:project/screens/settings.dart';
import 'package:project/screens/shop/pet_shop_screen.dart';
import 'package:project/screens/spa_booking/booking_history.dart';
import 'package:project/screens/spa_booking/spa_booking.dart';
import 'package:project/widgets/drawer_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialDrawer extends StatefulWidget {
  final String currentPage;
  const MaterialDrawer({super.key, required this.currentPage});

  @override
  _MaterialDrawerState createState() => _MaterialDrawerState();
}

class _MaterialDrawerState extends State<MaterialDrawer> {
  bool isLoading = false;
  final AppController appController = Get.put(AppController());
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  // Danh sách các mục trong Drawer
// Danh sách các mục trong Drawer sau khi sắp xếp lại
  final List<Map<String, dynamic>> drawerItems = [
    // Các mục chính của ứng dụng
    {
      'icon': Icons.home,
      'title': 'Home',
      'route': '/home',
      'screen': const HomeScreen(),
      'needLogin': false,
    },
    {
      'icon': Icons.calendar_month,
      'title': 'Spa Booking',
      'route': '/booking',
      'screen': const SpaBooking(),
      'needLogin': false,
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Pet Shop',
      'route': '/pet_shop',
      'screen': const PetShopScreen(),
      'needLogin': false,
    },
    {
      'icon': Icons.hotel,
      'title': 'Pet Hotel',
      'route': '/hotel',
      'screen': const RentPetHotel(),
      'needLogin': true,
    },
    {
      'icon': Icons.dashboard_customize,
      'title': 'Accessories Customization',
      'route': '/customization',
      'screen': const HomeScreen(),
      'needLogin': true,
    },
    // Các mục quản lý tài khoản
    {
      'icon': Icons.account_circle,
      'title': 'Profile',
      'route': '/profile',
      'screen': const Profile(),
      'needLogin': true,
    },
    {
      'icon': Icons.history,
      'title': 'Booking History',
      'route': '/booking_history',
      'screen': const BookingHistoryScreen(),
      'needLogin': true,
    },
    {
      'icon': Icons.settings,
      'title': 'App Settings',
      'route': '/settings',
      'screen': const Settings(),
      'needLogin': false,
    },

    {
      'icon': Icons.logout,
      'title': 'Log Out',
      'route': '/logout',
      'screen': const LogoutScreen(),
      'needLogin': false,
    },
    {
      'icon': Icons.login,
      'title': 'Login',
      'route': '/login',
      'screen': const LoginScreen(),
      'needLogin': false,
    },
    {
      'icon': Icons.person_add,
      'title': 'Register',
      'route': '/register',
      'screen': const RegisterScreen(),
      'needLogin': false,
    },
    // Mục khác
    {
      'icon': Icons.dashboard_customize,
      'title': 'Components',
      'route': '/component',
      'screen': const Components(),
      'needLogin': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (appController.isAuthenticated.value) {
      drawerItems.removeWhere((element) => element['route'] == '/login');
      drawerItems.removeWhere((element) => element['route'] == '/register');
    } else {
      drawerItems.removeWhere((element) => element['route'] == '/logout');
      drawerItems.removeWhere((element) => element['route'] == '/profile');
    }
    return Stack(
      children: [
        SafeArea(
          child: Drawer(
            child: Column(
              children: [
                Container(
                  // height: 200, // Tùy chỉnh chiều cao của DrawerHeader
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: const BoxDecoration(
                    color: MaterialColors.drawerHeader,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thêm Row chứa logo và nút đóng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: CircleAvatar(
                              backgroundImage: Image.asset("assets/img/logo.jpg").image,
                              radius: 30, // Điều chỉnh kích thước logo
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop(); // Đóng Drawer
                            },
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, top: 16.0),
                        child: Text(
                          "Pet Spa",
                          style: TextStyle(color: Colors.white, fontSize: 21),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: MaterialColors.label,
                                ),
                                child: const Text("Pro", style: TextStyle(color: Colors.white, fontSize: 16)),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Text("Seller", style: TextStyle(color: MaterialColors.muted, fontSize: 16)),
                            ),
                            const Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Text("999", style: TextStyle(color: MaterialColors.warning, fontSize: 16)),
                                ),
                                Icon(Icons.star_border, color: MaterialColors.warning, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: drawerItems.length,
                    itemBuilder: (context, index) {
                      final item = drawerItems[index];
                      bool checkLogin = false;
                      if (item['needLogin']) {
                        // Nếu mục này yêu cầu đăng nhập và người dùng chưa đăng nhập, thì checkLogin = true
                        checkLogin = !appController.isAuthenticated.value;
                      }

                      return DrawerItem(
                        icon: item['icon'],
                        title: item['title'],
                        route: item['route'],
                        screen: item['screen'],
                        currentPage: widget.currentPage,
                        needLogin: checkLogin,
                        context: context,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(color: MaterialColors.primary),
            ),
          ),
      ],
    );
  }
}
