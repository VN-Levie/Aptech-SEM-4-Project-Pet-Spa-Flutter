import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final VoidCallback onTap;

  const ServiceCard({super.key, 
    required this.title,
    required this.description,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text('$description - $price đ'),
        onTap: onTap,
      ),
    );
  }
}
