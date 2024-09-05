import 'package:flutter/material.dart';

class CardCategory extends StatelessWidget {
  const CardCategory(
      {super.key, this.title = "Placeholder Title",
      this.img = "https://via.placeholder.com/250",
      this.tap = defaultFunc});

  final String img;
  final void Function()? tap;
  final String title;

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 252,
        width: null,
        child: GestureDetector(
          onTap: tap,
          child: Card(
              elevation: 1,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0))),
              child: Stack(children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                        image: DecorationImage(
                          image: NetworkImage(img),
                          fit: BoxFit.cover,
                        ))),
                Container(
                    decoration: const BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.all(Radius.circular(6.0)))),
                Center(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.0)),
                )
              ])),
        ));
  }
}
