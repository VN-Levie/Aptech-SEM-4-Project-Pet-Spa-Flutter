import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/core/app_controller.dart';
import 'package:project/core/rest_service.dart';
import 'package:project/models/account.dart';
import 'package:project/models/spa_service.dart';
import 'package:project/screens/auth/login_screen.dart';
import 'package:project/widgets/utils.dart';

class CardSpaService extends StatelessWidget {
  const CardSpaService({
    super.key,
    required this.service,
    required this.onTap,
  });

  final SpaService service;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 252,
      width: double.infinity, // Điều chỉnh để thẻ chiếm toàn bộ chiều rộng
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Card(
          elevation: 1,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
          child: Stack(
            children: [
              // Sử dụng CachedNetworkImage với BoxFit.cover
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: CachedNetworkImage(
                  imageUrl: Utils.replaceLocalhost(service.imageUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.all(Radius.circular(6.0))),
              ),
                Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                    service.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                    service.description,
                    style: const TextStyle(color: Colors.white, fontSize: 14.0),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    ),
                  ],
                  ),
                ),
                ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
