import 'dart:io';

import 'package:flutter/material.dart';

class AlbumArt extends StatelessWidget {
  final String? imagePath;
  final double size;
  final double borderRadius;

  const AlbumArt({
    super.key,
    this.imagePath,
    this.size = 100,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: const Color(0xFF282828),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imagePath != null
            ? Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAlbumArt();
                },
              )
            : _buildDefaultAlbumArt(),
      ),
    );
  }

  Widget _buildDefaultAlbumArt() {
    return const Center(
      child: Icon(
        Icons.music_note,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}