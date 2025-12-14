import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShuffleButton(),
            const SizedBox(width: 40),
            _buildRepeatButton(),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPreviousButton(),
            
            _buildPlayPauseButton(),
            
            _buildNextButton(),
          ],
        ),
      ],
    );
  }


  Widget _buildShuffleButton() {
    return IconButton(
      icon: Icon(
        Icons.shuffle,
        color: provider.isShuffleEnabled
            ? const Color(0xFF1DB954)
            : Colors.grey,
      ),
      onPressed: provider.playlist.isNotEmpty
          ? () => provider.toggleShuffle()
          : null, 
    );
  }

  Widget _buildRepeatButton() {
    IconData icon;
    Color color;

    switch (provider.loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = Colors.grey;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = const Color(0xFF1DB954);
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = const Color(0xFF1DB954);
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: provider.playlist.isNotEmpty
          ? () => provider.toggleRepeat()
          : null,
    );
  }

  Widget _buildPreviousButton() {
    return IconButton(
      icon: const Icon(
        Icons.skip_previous,
        color: Colors.white,
        size: 40,
      ),
      onPressed: provider.playlist.isNotEmpty
          ? () => provider.previous()
          : null,
    );
  }

  Widget _buildNextButton() {
    return IconButton(
      icon: const Icon(
        Icons.skip_next,
        color: Colors.white,
        size: 40,
      ),
      onPressed: provider.playlist.isNotEmpty
          ? () => provider.next()
          : null,
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder<bool>(
      stream: provider.playingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(' Error in playingStream: ${snapshot.error}');
          return _buildDefaultPlayButton(false);
        }

        if (!snapshot.hasData) {
          return _buildDefaultPlayButton(false);
        }

        final isPlaying = snapshot.data!;
        return _buildPlayPauseIcon(isPlaying);
      },
    );
  }

  Widget _buildDefaultPlayButton(bool isPlaying) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1DB954),
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
        onPressed: provider.playlist.isNotEmpty
            ? () => provider.playPause()
            : null,
      ),
    );
  }

  Widget _buildPlayPauseIcon(bool isPlaying) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1DB954),
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () {
          try {
            provider.playPause();
          } catch (e) {
            print('Error in playPause: $e');
          }
        },
      ),
    );
  }
}