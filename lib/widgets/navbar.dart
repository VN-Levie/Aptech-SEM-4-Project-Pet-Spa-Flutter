import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:pet_spa/constants/Theme.dart';

// import 'package:pet_spa/screens/categories.dart';
// import 'package:pet_spa/screens/best-deals.dart';
// import 'package:pet_spa/screens/search.dart';
// import 'package:pet_spa/screens/cart.dart';
// import 'package:pet_spa/screens/chat.dart';

import 'package:pet_spa/widgets/input.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  late String title;
  late String categoryOne;
  late String categoryTwo;
  late bool searchBar;
  late bool backButton;
  late bool transparent;
  late bool rightOptions;
  late List<String>? tags;
  late Function? getCurrentPage;
  late bool isOnSearch;
  late TextEditingController? searchController;
  late Function? searchOnChanged;
  late bool searchAutofocus;
  late bool noShadow;
  late Color bgColor;

  Navbar({super.key, this.title = "Home", this.categoryOne = "", this.categoryTwo = "", this.tags, this.transparent = false, this.rightOptions = true, this.getCurrentPage, this.searchController, this.isOnSearch = false, this.searchOnChanged, this.searchAutofocus = false, this.backButton = false, this.noShadow = false, this.bgColor = Colors.white, this.searchBar = false});

  final double _prefferedHeight = 180.0;

  @override
  _NavbarState createState() => _NavbarState();

  @override
  Size get preferredSize => Size.fromHeight(_prefferedHeight);
}

class _NavbarState extends State<Navbar> {
  late String activeTag;

  final ItemScrollController _scrollController = ItemScrollController();

  @override
  void initState() {
    if (widget.tags != null && widget.tags?.length != 0) {
      activeTag = widget.tags![0];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late bool categories = widget.categoryOne.isNotEmpty && widget.categoryTwo.isNotEmpty;
    late bool tagsExist = widget.tags == null ? false : (widget.tags?.length == 0 ? false : true);

    return Container(
        height: widget.searchBar ? (!categories ? (tagsExist ? 211.0 : 178.0) : (tagsExist ? 262.0 : 210.0)) : (!categories ? (tagsExist ? 132.0 : 102.0) : (tagsExist ? 200.0 : 150.0)),
        decoration: BoxDecoration(color: !widget.transparent ? widget.bgColor : Colors.transparent, boxShadow: [
          BoxShadow(color: !widget.transparent && !widget.noShadow ? Colors.black.withOpacity(0.6) : Colors.transparent, spreadRadius: -10, blurRadius: 12, offset: const Offset(0, 5))
        ]),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: Icon(!widget.backButton ? Icons.menu : Icons.arrow_back_ios, color: !widget.transparent ? (widget.bgColor == Colors.white ? Colors.black : Colors.white) : Colors.white, size: 24.0),
                            onPressed: () {
                              if (!widget.backButton) {
                                Scaffold.of(context).openDrawer();
                              } else {
                                Navigator.pop(context);
                              }
                            }),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(widget.title, style: TextStyle(color: !widget.transparent ? (widget.bgColor == Colors.white ? Colors.black : Colors.white) : Colors.white, fontWeight: FontWeight.w600, fontSize: 18.0)),
                        ),
                      ],
                    ),
                    if (widget.rightOptions)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Chat()));
                            },
                            child: IconButton(icon: Icon(Icons.chat_bubble_outline, color: !widget.transparent ? (widget.bgColor == Colors.white ? Colors.black : Colors.white) : Colors.white, size: 22.0), onPressed: null),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => Cart()));
                            },
                            child: IconButton(icon: Icon(Icons.add_shopping_cart, color: !widget.transparent ? (widget.bgColor == Colors.white ? Colors.black : Colors.white) : Colors.white, size: 22.0), onPressed: null),
                          ),
                        ],
                      )
                  ],
                ),
                if (widget.searchBar)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4, left: 15, right: 15),
                    child: Input(
                        placeholder: "What are you looking for?",
                        controller: widget.searchController!,
                        onChanged: widget.searchOnChanged as void Function(String)? ?? (String value) {},
                        autofocus: widget.searchAutofocus,
                        outlineBorder: true,
                        enabledBorderColor: Colors.black.withOpacity(0.2),
                        focusedBorderColor: MaterialColors.muted,
                        suffixIcon: const Icon(Icons.zoom_in, color: MaterialColors.muted),
                        onTap: () {
                          // if (!widget.isOnSearch)
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => Search()));
                        }),
                  ),
                SizedBox(
                  height: tagsExist ? 0 : 10,
                ),
                if (categories)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => Categories()));
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.border_all, color: Colors.black87, size: 22.0),
                            const SizedBox(width: 10),
                            Text(widget.categoryOne, style: const TextStyle(color: Colors.black87, fontSize: 16.0)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      Container(
                        color: MaterialColors.muted,
                        height: 25,
                        width: 0.3,
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => BestDeals()));
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.camera_enhance, color: Colors.black87, size: 22.0),
                            const SizedBox(width: 10),
                            Text(widget.categoryTwo, style: const TextStyle(color: Colors.black87, fontSize: 16.0)),
                          ],
                        ),
                      )
                    ],
                  ),
                if (tagsExist)
                  SizedBox(
                    height: 40,
                    child: ScrollablePositionedList.builder(
                      itemScrollController: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.tags!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            if (activeTag != widget.tags?[index]) {
                              setState(() => activeTag = widget.tags![index]);
                              _scrollController.scrollTo(index: index == widget.tags!.length - 1 ? 1 : 0, duration: const Duration(milliseconds: 420), curve: Curves.easeIn);
                              if (widget.getCurrentPage != null) widget.getCurrentPage!(activeTag);
                            }
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: index == 0 ? 46 : 8, right: 8),
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2.0, color: activeTag == widget.tags?[index] ? MaterialColors.primary : Colors.transparent))),
                              child: Center(
                                child: Text(widget.tags![index], style: TextStyle(color: activeTag == widget.tags?[index] ? MaterialColors.primary : MaterialColors.placeholder, fontWeight: FontWeight.w500, fontSize: 14.0)),
                              )),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
        ));
  }
}
