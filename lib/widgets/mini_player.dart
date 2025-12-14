import 'dart:io';
import 'package:flutter/material.dart';
import 'package:offline_music_player/screens/now_playing_screen.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../models/playback_state_model.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      },
      onHorizontalDragEnd: (details) {
        final audioProvider = Provider.of<AudioProvider>(
          context,
          listen: false,
        );
        if (details.primaryVelocity! > 0) {
          audioProvider.previous();
        } else if (details.primaryVelocity! < 0) {
          audioProvider.next();
        }
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<AudioProvider>(
          builder: (context, provider, child) {
            final song = provider.currentSong;

            if (song == null) return const SizedBox.shrink();

            return Column(
              children: [
                StreamBuilder<PlaybackState>(
                  stream: provider.playbackStateStream,
                  initialData: PlaybackState(
                    position: Duration.zero,
                    duration: Duration.zero,
                    isPlaying: false,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return LinearProgressIndicator(
                        value: 0.0,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1DB954),
                        ),
                        minHeight: 2,
                      );
                    }

                    final progress = snapshot.data?.progress ?? 0.0;
                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1DB954),
                      ),
                      minHeight: 2,
                    );
                  },
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[800],
                          ),
                          child: song.albumArt != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.file(
                                    File(song.albumArt!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAlbumArt();
                                    },
                                  ),
                                )
                              : _buildDefaultAlbumArt(),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        StreamBuilder<bool>(
                          stream: provider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                              onPressed: () => provider.playPause(),
                            );
                          },
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                          ),
                          onPressed: () => provider.next(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultAlbumArt() {
    return const Icon(Icons.music_note, color: Colors.grey);
  }
}
