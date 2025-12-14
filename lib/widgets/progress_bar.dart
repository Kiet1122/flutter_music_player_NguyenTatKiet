import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const ProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final double maxDuration = duration.inMilliseconds.toDouble();
    final double currentPosition = position.inMilliseconds.toDouble();
    final bool isDurationValid = maxDuration > 0;
    
    final double sliderValue = isDurationValid 
        ? currentPosition.clamp(0.0, maxDuration)
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: const Color(0xFF1DB954),
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF1DB954).withOpacity(0.3),
          ),
          child: Slider(
            value: sliderValue,
            min: 0.0,
            max: isDurationValid ? maxDuration : 1.0,
            onChanged: isDurationValid 
                ? (value) {
                    onSeek(Duration(milliseconds: value.toInt()));
                  }
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inSeconds == 0) {
      return '00:00';
    }
    
    return '$minutes:$seconds';
  }
}