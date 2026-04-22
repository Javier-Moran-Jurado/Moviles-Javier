import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CustomCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}