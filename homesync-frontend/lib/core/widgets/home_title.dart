import 'package:flutter/material.dart';

/// AppBar title that always navigates back to the root home page.
class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label),
      ),
    );
  }
}
