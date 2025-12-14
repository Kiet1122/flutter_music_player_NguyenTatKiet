import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback? onOptionsPressed;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    print('=== Building SongTile: ${song.title} ===');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
        ),
        title: Text(
          song.title.length > 30
              ? '${song.title.substring(0, 30)}...'
              : song.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () {
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
