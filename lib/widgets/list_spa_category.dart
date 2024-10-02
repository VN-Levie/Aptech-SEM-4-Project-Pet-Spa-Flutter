import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Thêm import cho cached_network_image

import 'package:project/constants/theme.dart';
import 'package:project/screens/spa_booking/service_selection.dart';
import 'package:project/widgets/utils.dart';
import 'package:shimmer/shimmer.dart';

class SpaCategoryCarousel extends StatefulWidget {
  final List<Map<String, String>> imgArray;

  const SpaCategoryCarousel({
    super.key,
    required this.imgArray,
  });

  @override
  _SpaCategoryCarouselState createState() => _SpaCategoryCarouselState();
}

class _SpaCategoryCarouselState extends State<SpaCategoryCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: widget.imgArray
          .map((item) => GestureDetector(
                onTap: () {
                  Utils.navigateTo(context, ServiceSelection(categoryId: int.parse(item['id'] ?? '0')));
                },
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.4), blurRadius: 8, spreadRadius: 0.3, offset: Offset(0, 3))
                          ]),
                          child: AspectRatio(
                            aspectRatio: 2 / 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: item["img"] ?? "",
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: MaterialColors.primary.withOpacity(0.8),
                                  highlightColor: MaterialColors.primary.withOpacity(0.5),
                                  child: Container(
                                    width: double.infinity,
                                    color: MaterialColors.placeholder,
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Column(
                          children: [
                            Text(item["name"] ?? "name", style: const TextStyle(fontSize: 32, color: Colors.black)),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
                              child: Text(
                                item["description"] ?? "description",
                                style: const TextStyle(fontSize: 16, color: MaterialColors.muted),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ))
          .toList(),
      options: CarouselOptions(
          height: 530,
          autoPlay: true,
          enlargeCenterPage: false,
          aspectRatio: 4 / 4,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 3),
          initialPage: 0,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
    );
  }
}

class SpaDetailPage extends StatelessWidget {
  final String id;

  const SpaDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spa Detail'),
      ),
      body: Center(
        child: Text('Spa Detail for ID: $id'),
      ),
    );
  }
}
