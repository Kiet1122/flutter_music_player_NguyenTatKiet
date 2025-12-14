import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class SpeedControl extends StatefulWidget {
  const SpeedControl({super.key});

  @override
  State<SpeedControl> createState() => _SpeedControlState();
}

class _SpeedControlState extends State<SpeedControl> {
  double _speed = 1.0;
  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.speed, color: Colors.white),
        const SizedBox(width: 8),
        DropdownButton<double>(
          value: _speed,
          dropdownColor: const Color(0xFF282828),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          underline: Container(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _speed = value;
              });
              Provider.of<AudioProvider>(context, listen: false).setSpeed(value);
            }
          },
          items: _speeds.map((speed) {
            return DropdownMenuItem<double>(
              value: speed,
              child: Text(
                '${speed}x',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}