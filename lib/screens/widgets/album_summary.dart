// lib/widgets/album_summary.dart
import 'package:flutter/material.dart';

class AlbumSummary extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const AlbumSummary({
    Key? key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundColor: color,
            radius: 24.0,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        Text(
          title,
          style: const TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }
}
