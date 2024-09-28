import 'package:flutter/material.dart';
import 'package:project/constants/Theme.dart';
import 'package:project/screens/home.dart';
import 'package:project/screens/pet_hotel/rent_pet_hotel.dart';
import 'package:project/widgets/drawer-tile.dart';
import 'package:project/screens/components.dart';
import 'package:project/screens/onboarding.dart';
import 'package:project/screens/profile.dart';
import 'package:project/screens/settings.dart';
import 'package:project/screens/spa_booking/booking_history.dart';
import 'package:project/screens/spa_booking/spa_booking.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/screens/auth/register_screen.dart';
import 'package:project/screens/shop/pet_shop_screen.dart';

class MaterialDrawer extends StatefulWidget {
  final String currentPage;

  const MaterialDrawer({super.key, required this.currentPage});

  @override
  _MaterialDrawerState createState() => _MaterialDrawerState();
}

class _MaterialDrawerState extends State<MaterialDrawer> {
  bool isLoading = false; // Loading state

  // Function to handle page transitions with loading effect
  void navigateWithLoading(BuildContext context, String route) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Simulate a delay to show the loading effect
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      isLoading = false; // Hide loading indicator after the delay
    });

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => getPageByRoute(route),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  // Function to return the correct page based on the route
  Widget getPageByRoute(String route) {
    print(route);
    switch (route) {
      case '/home':
        return const Home();
      case '/booking':
        return const SpaBooking();
      case '/pet_shop':
        return const PetShopScreen();
      case '/hotel':
        return const RentPetHotel();
      case '/customization':
        return const Home();
      case '/profile':
        return const Profile();
      case '/settings':
        return const Settings();
      case '/booking_history':
        return const BookingHistoryScreen();
      case '/login':
        return const LoginScreen();
      case '/register':
        return const RegisterScreen();
      case '/component':
        return const Components();
      case '/onboarding':
        return const Onboarding();

      default:
        return const Home();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: MaterialColors.drawerHeader),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: Image.asset("assets/img/logo.jpg").image,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 16.0),
                      child: Text("Pet Spa", style: TextStyle(color: Colors.white, fontSize: 21)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: MaterialColors.label),
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
                              Icon(Icons.star_border, color: MaterialColors.warning, size: 20)
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  children: [
                    DrawerTile(
                      icon: Icons.home,
                      onTap: () {
                        if (widget.currentPage != "Home") navigateWithLoading(context, '/home');
                      },
                      iconColor: Colors.black,
                      title: "Home",
                      isSelected: widget.currentPage == "Home",
                    ),
                    DrawerTile(
                      icon: Icons.calendar_month,
                      onTap: () {
                        if (widget.currentPage != "booking") navigateWithLoading(context, '/booking');
                      },
                      iconColor: Colors.black,
                      title: "Spa Booking",
                      isSelected: widget.currentPage == "booking",
                    ),
                    DrawerTile(
                      icon: Icons.shopping_cart,
                      onTap: () {
                        if (widget.currentPage != "pet_shop") navigateWithLoading(context, '/pet_shop');
                      },
                      iconColor: Colors.black,
                      title: "Pet Shop",
                      isSelected: widget.currentPage == "pet_shop",
                    ),
                    DrawerTile(
                      icon: Icons.hotel,
                      onTap: () {
                        if (widget.currentPage != "hotel") navigateWithLoading(context, '/hotel');
                      },
                      iconColor: Colors.black,
                      title: "Pet Hotel",
                      isSelected: widget.currentPage == "hotel",
                    ),
                    DrawerTile(
                      icon: Icons.dashboard_customize,
                      onTap: () {
                        if (widget.currentPage != "customization") navigateWithLoading(context, '/customization');
                      },
                      iconColor: Colors.black,
                      title: "Accessories Customization",
                      isSelected: widget.currentPage == "customization",
                    ),
                    DrawerTile(
                      icon: Icons.account_circle,
                      onTap: () {
                        if (widget.currentPage != "Profile") navigateWithLoading(context, '/profile');
                      },
                      iconColor: Colors.black,
                      title: "Profile",
                      isSelected: widget.currentPage == "Profile",
                    ),
                    DrawerTile(
                      icon: Icons.settings,
                      onTap: () {
                        if (widget.currentPage != "Settings") navigateWithLoading(context, '/settings');
                      },
                      iconColor: Colors.black,
                      title: "App Settings",
                      isSelected: widget.currentPage == "Settings",
                    ),
                    DrawerTile(
                      icon: Icons.history,
                      onTap: () {
                        if (widget.currentPage != "booking_history") navigateWithLoading(context, '/booking_history');
                      },
                      iconColor: Colors.black,
                      title: "Booking History",
                      isSelected: widget.currentPage == "booking_history",
                    ),
                    DrawerTile(
                      icon: Icons.logout,
                      onTap: () {
                        if (widget.currentPage != "login") navigateWithLoading(context, '/login');
                      },
                      iconColor: Colors.black,
                      title: "Log Out",
                      isSelected: widget.currentPage == "login",
                    ),
                    //view components
                    DrawerTile(
                      icon: Icons.dashboard_customize,
                      onTap: () {
                        if (widget.currentPage != "component") navigateWithLoading(context, '/component');
                      },
                      iconColor: Colors.black,
                      title: "Components",
                      isSelected: widget.currentPage == "component",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          const Positioned(
            bottom: 20, // Adjust this value as needed to position near the button
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(color: MaterialColors.primary), // Circular progress indicator near button
            ),
          ),
      ],
    );
  }
}
