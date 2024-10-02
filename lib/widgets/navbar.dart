import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:project/constants/theme.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/screens/shop/cart.screen.dart';
import 'package:project/widgets/utils.dart'; // Import AppController

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String categoryOne;
  final String categoryTwo;
  final bool searchBar;
  final bool backButton;
  final bool transparent;
  final bool rightOptions;
  final List<String>? tags;
  final Function? getCurrentPage;
  final bool isOnSearch;
  final TextEditingController? searchController;
  final Function(String)? searchOnSubmitted;
  final bool searchAutofocus;
  final bool noShadow;
  final Color bgColor;
  final bool isLoading;

  const Navbar({
    super.key,
    this.title = "Home",
    this.categoryOne = "",
    this.categoryTwo = "",
    this.tags,
    this.transparent = false,
    this.rightOptions = true,
    this.getCurrentPage,
    this.searchController,
    this.isOnSearch = false,
    this.searchOnSubmitted,
    this.searchAutofocus = false,
    this.backButton = false,
    this.noShadow = false,
    this.bgColor = MaterialColors.drawerHeader,
    this.searchBar = false,
    this.isLoading = false,
  });

  final double _preferredHeight = 180.0;

  @override
  Size get preferredSize => Size.fromHeight(_preferredHeight);

  @override
  Widget build(BuildContext context) {
    // Lấy AppController
    final AppController appController = Get.put(AppController());
    // final AppController appController = Get.lazyPut(()=>AppController());

    return Container(
      height: searchBar ? (!categoryOne.isNotEmpty || !categoryTwo.isNotEmpty ? (tags != null && tags!.isNotEmpty ? 211.0 : 178.0) : (tags != null && tags!.isNotEmpty ? 262.0 : 210.0)) : (!categoryOne.isNotEmpty || !categoryTwo.isNotEmpty ? (tags != null && tags!.isNotEmpty ? 132.0 : 102.0) : (tags != null && tags!.isNotEmpty ? 200.0 : 150.0)),
      decoration: BoxDecoration(
        color: !transparent ? bgColor : Colors.transparent,
        boxShadow: [
          if (!transparent && !noShadow)
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: -10,
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  !backButton ? Icons.menu : Icons.arrow_back_ios,
                                  color: !transparent ? (bgColor == Colors.white ? Colors.black : Colors.white) : MaterialColors.drawerHeader,
                                  size: 28.0,
                                ),
                                onPressed: () {
                                  if (!backButton) {
                                    Scaffold.of(context).openDrawer();
                                  } else {
                                    Navigator.pop(context);
                                    //update lại cart badges
                                 
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                title,
                                style: TextStyle(
                                  color: !transparent ? (bgColor == Colors.white ? Colors.black : Colors.white) : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22.0,                                  
                                ),
                                overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                                maxLines: 1, // Đảm bảo chỉ hiển thị một dòng
                              ),
                            ],
                          ),
                          if (rightOptions)
                            Row(
                              children: [
                                // Chat icon with GetX badge
                                Obx(() => badges.Badge(
                                      badgeContent: Text(
                                        appController.unreadMessages.value.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                      showBadge: appController.unreadMessages.value > 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.chat_bubble_outline,
                                          color: !transparent ? (bgColor == Colors.white ? Colors.black : Colors.white) : Colors.white,
                                          size: 24.0,
                                        ),
                                        onPressed: () {
                                          // Xử lý sự kiện bấm nút chat
                                        },
                                      ),
                                    )),
                                const SizedBox(width: 10),
                                // Cart icon with GetX badge
                                Obx(() => badges.Badge(
                                      badgeContent: Text(
                                        appController.numberOfCartItems.value.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                      showBadge: appController.numberOfCartItems.value > 0,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.shopping_cart_outlined,
                                          color: !transparent ? (bgColor == Colors.white ? Colors.black : Colors.white) : Colors.white,
                                          size: 24.0,
                                        ),
                                        onPressed: () {
                                          // ShoppingCartPage
                                          Utils.navigateTo(context, ShoppingCartPage());
                                        },
                                      ),
                                    )),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 10),
                    // Search Bar
                    if (searchBar)
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 12), // Reduced top padding to lower the search bar
                        child: TextField(
                          controller: searchController,
                          onSubmitted: searchOnSubmitted,
                          autofocus: searchAutofocus,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchController != null && searchController?.text.isNotEmpty == true
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController?.clear();
                                      searchOnSubmitted?.call("");
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: MaterialColors.primary),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
