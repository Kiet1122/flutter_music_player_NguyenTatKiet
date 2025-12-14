import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class VolumeControl extends StatefulWidget {
  final bool showSlider;

  const VolumeControl({super.key, this.showSlider = false});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double _volume = 1.0;
  bool _muted = false;
  double _previousVolume = 1.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _muted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
          ),
          onPressed: () {
            final audioProvider = Provider.of<AudioProvider>(context, listen: false);
            setState(() {
              _muted = !_muted;
              if (_muted) {
                _previousVolume = _volume;
                _volume = 0.0;
              } else {
                _volume = _previousVolume;
              }
              audioProvider.setVolume(_volume);
            });
          },
        ),

        if (widget.showSlider)
          SizedBox(
            width: 100,
            child: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _volume = value;
                  _muted = value == 0.0;
                });
                Provider.of<AudioProvider>(context, listen: false).setVolume(value);
              },
              activeColor: const Color(0xFF1DB954),
              inactiveColor: Colors.grey[800],
            ),
          ),
      ],
    );
  }
}