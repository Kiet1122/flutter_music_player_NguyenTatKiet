import 'dart:io';
import 'package:flutter/material.dart';
import 'package:offline_music_player/models/playback_state_model.dart';
import 'package:offline_music_player/utils/safe_stream_builder.dart';
import 'package:offline_music_player/widgets/player_controls.dart';
import 'package:offline_music_player/widgets/progress_bar.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../models/song_model.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return const Center(
              child: Text(
                'No song playing',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAlbumArt(song),

                        const SizedBox(height: 40),
                        _buildSongInfo(song),

                        const SizedBox(height: 40),

                        SafeStreamBuilder<PlaybackState>(
                          stream: provider.playbackStateStream,
                          initialData: PlaybackState(
                            position: Duration.zero,
                            duration: Duration.zero,
                            isPlaying: false,
                          ),
                          builder: (context, state) {
                            final playbackState = state.data!;

                            return ProgressBar(
                              position: playbackState.position,
                              duration: playbackState.duration,
                              onSeek: provider.seek,
                            );
                          },
                          errorWidget: ProgressBar(
                            position: Duration.zero,
                            duration: Duration.zero,
                            onSeek: (_) {},  
                          ),
                        ),

                        const SizedBox(height: 20),

                        PlayerControls(provider: provider),

                        const SizedBox(height: 20),

                        _buildAdditionalControls(provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Now Playing',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(SongModel song) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: song.albumArt != null
            ? Image.file(
                File(song.albumArt!),
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
    return Container(
      color: const Color(0xFF282828),
      child: const Icon(Icons.music_note, size: 100, color: Colors.grey),
    );
  }

  Widget _buildSongInfo(SongModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          song.artist,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        if (song.album != null) ...[
          const SizedBox(height: 4),
          Text(
            song.album!,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalControls(AudioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StreamBuilder<double>(
          stream: Stream<double>.periodic(const Duration(milliseconds: 100))
              .asyncMap((_) async {
                return 0.7;
              }),
          builder: (context, snapshot) {
            final volume = snapshot.data ?? 0.7;
            return Row(
              children: [
                const Icon(Icons.volume_down, color: Colors.grey),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      provider.setVolume(value);
                    },
                    activeColor: const Color(0xFF1DB954),
                    inactiveColor: Colors.grey[800],
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.grey),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final provider = Provider.of<AudioProvider>(context, listen: false);
    final song = provider.currentSong;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text(
                  'Song Info',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: song != null
                    ? () {
                        Navigator.pop(context);

                        final currentSong = provider.currentSong;
                        if (currentSong != null) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (context.mounted) {
                              _showSongInfoDialog(context, currentSong);
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cannot show song info'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null, 
              ),

              ListTile(
                leading: const Icon(Icons.queue_music, color: Colors.white),
                title: const Text(
                  'Add to Queue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to queue'),
                      backgroundColor: Color(0xFF1DB954),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.playlist_add, color: Colors.white),
                title: const Text(
                  'Add to Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSongInfoDialog(BuildContext context, SongModel song) {
    if (song == null || song.title.isEmpty) {
      print('Song is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot show song info'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Song Information',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (song.title.isNotEmpty) _buildInfoRow('Title', song.title),
                if (song.artist.isNotEmpty)
                  _buildInfoRow('Artist', song.artist),
                if (song.album != null && song.album!.isNotEmpty)
                  _buildInfoRow('Album', song.album!),
                if (song.duration != null)
                  _buildInfoRow('Duration', _formatDuration(song.duration!)),
                if (song.filesize != null && song.filesize! > 0)
                  _buildInfoRow(
                    'File Size',
                    '${(song.filesize! / 1024 / 1024).toStringAsFixed(2)} MB',
                  ),
                if (song.filePath.isNotEmpty)
                  _buildInfoRow('File Path', song.filePath),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFF1DB954)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == null || duration.isNegative) {
      return '00:00';
    }

    String twoDigits(int n) {
      if (n == null) return '00';
      return n.toString().padLeft(2, '0');
    }

    try {
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      return '$minutes:$seconds';
    } catch (e) {
      return '00:00'; 
    }
  }
}
