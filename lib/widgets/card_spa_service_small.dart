import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project/constants/theme.dart';
import 'package:shimmer/shimmer.dart';

class SpaServiceCardSmall extends StatelessWidget {
  const SpaServiceCardSmall({super.key, required this.title, required this.img, required this.description});

  final String img;
  final String title;
  final String description; 

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 130,
        margin: const EdgeInsets.only(top: 10),
        child: GestureDetector(
          child: Stack(clipBehavior: Clip.hardEdge, children: [
            Card(
              elevation: 0.7,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
              child: Row(
                children: [
                  Flexible(flex: 1, child: Container()),
                  Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: MaterialColors.caption,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              description,
                              style: const TextStyle(
                                color: MaterialColors.muted,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ))
                ],
              ),
            ),
            FractionalTranslation(
              translation: const Offset(0.04, -0.08),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    // padding: const EdgeInsets.all(4.0),
                    height: MediaQuery.of(context).size.height / 2,
                    width: 165,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), spreadRadius: 2, blurRadius: 1, offset: const Offset(0, 0))
                    ], borderRadius: const BorderRadius.all(Radius.circular(4.0))),
                    child: CachedNetworkImage(
                      imageUrl: img,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )),
              ),
            ),
          ]),
        ));
  }
}
