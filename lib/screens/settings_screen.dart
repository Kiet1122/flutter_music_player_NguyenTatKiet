import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offline_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        foregroundColor: themeProvider.textColor,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('App Settings'),
          _buildCard(
            children: [
              _buildSettingItem(
                icon: Icons.color_lens,
                title: 'Theme',
                subtitle: themeProvider.themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: themeProvider.primaryColor,
                ),
                onTap: () {
                  themeProvider.toggleTheme();
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.music_note,
                title: 'Audio Quality',
                subtitle: 'High quality playback',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showAudioQualityDialog(context, audioProvider);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Playback Settings'),
          _buildCard(
            children: [
              StreamBuilder<bool>(
                stream: audioProvider.playingStream,
                builder: (context, snapshot) {
                  return _buildSettingItem(
                    icon: Icons.shuffle,
                    title: 'Shuffle',
                    subtitle: 'Play songs in random order',
                    trailing: Switch(
                      value: audioProvider.isShuffleEnabled,
                      onChanged: (value) {
                        audioProvider.toggleShuffle();
                      },
                      activeColor: themeProvider.primaryColor,
                    ),
                    onTap: () {
                      audioProvider.toggleShuffle();
                    },
                  );
                },
              ),
              _buildDivider(),
              StreamBuilder<LoopMode>(
                stream: Stream.value(audioProvider.loopMode),
                builder: (context, snapshot) {
                  final loopMode = snapshot.data ?? LoopMode.off;
                  String loopText = 'Off';
                  if (loopMode == LoopMode.all) loopText = 'All';
                  if (loopMode == LoopMode.one) loopText = 'One';

                  return _buildSettingItem(
                    icon: Icons.repeat,
                    title: 'Repeat',
                    subtitle: loopText,
                    trailing: Switch(
                      value: loopMode != LoopMode.off,
                      onChanged: (value) {
                        audioProvider.toggleRepeat();
                      },
                      activeColor: themeProvider.primaryColor,
                    ),
                    onTap: () {
                      audioProvider.toggleRepeat();
                    },
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.speed,
                title: 'Playback Speed',
                subtitle: '1.0x',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showPlaybackSpeedDialog(context, audioProvider);
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.volume_up,
                title: 'Volume',
                subtitle: 'Adjust playback volume',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showVolumeDialog(context, audioProvider);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Storage & Data'),
          _buildCard(
            children: [
              _buildSettingItem(
                icon: Icons.storage,
                title: 'Clear Cache',
                subtitle: 'Remove temporary files',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _clearCache(context);
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.delete,
                title: 'Clear All Data',
                subtitle: 'Reset app to default settings',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _clearAllData(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('About'),
          _buildCard(
            children: [
              _buildSettingItem(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.code,
                title: 'Source Code',
                subtitle: 'GitHub Repository',
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.bug_report,
                title: 'Report Bug',
                subtitle: 'Help us improve the app',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                },
              ),
            ],
          ),

          const SizedBox(height: 40),

          Center(
            child: Column(
              children: [
                Text(
                  'Offline Music Player',
                  style: TextStyle(
                    color: themeProvider.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '© 2024 Flutter Music Player',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Colors.grey,
      indent: 16,
      endIndent: 16,
    );
  }

  void _showAudioQualityDialog(BuildContext context, AudioProvider audioProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Audio Quality',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQualityOption(
                context,
                'High Quality',
                'Best audio quality (uses more data)',
                true,
              ),
              _buildDivider(),
              _buildQualityOption(
                context,
                'Normal Quality',
                'Balanced quality and performance',
                false,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQualityOption(BuildContext context, String title, String subtitle, bool isSelected) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio quality set to $title'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  void _showPlaybackSpeedDialog(BuildContext context, AudioProvider audioProvider) {
    final List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    double currentSpeed = 1.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF282828),
              title: const Text(
                'Playback Speed',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: currentSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    label: '${currentSpeed}x',
                    onChanged: (value) {
                      setState(() {
                        currentSpeed = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Colors.grey[800],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: speeds.map((speed) {
                      return ChoiceChip(
                        label: Text('${speed}x'),
                        selected: currentSpeed == speed,
                        onSelected: (_) {
                          setState(() {
                            currentSpeed = speed;
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: currentSpeed == speed ? Colors.white : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    audioProvider.setSpeed(currentSpeed);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Playback speed set to ${currentSpeed}x'),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showVolumeDialog(BuildContext context, AudioProvider audioProvider) {
    double currentVolume = 1.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF282828),
              title: const Text(
                'Volume Control',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.volume_mute, color: Colors.grey),
                      Expanded(
                        child: Slider(
                          value: currentVolume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          label: '${(currentVolume * 100).toInt()}%',
                          onChanged: (value) {
                            setState(() {
                              currentVolume = value;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                          inactiveColor: Colors.grey[800],
                        ),
                      ),
                      const Icon(Icons.volume_up, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildVolumePreset(context, '25%', 0.25, setState),
                      _buildVolumePreset(context, '50%', 0.5, setState),
                      _buildVolumePreset(context, '75%', 0.75, setState),
                      _buildVolumePreset(context, '100%', 1.0, setState),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    audioProvider.setVolume(currentVolume);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Volume set to ${(currentVolume * 100).toInt()}%'),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVolumePreset(BuildContext context, String label, double value, StateSetter setState) {
    return TextButton(
      onPressed: () {
        setState(() {
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Future<void> _clearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Clear Cache',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will remove temporary files but keep your playlists and settings.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cache cleared successfully'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Clear All Data',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will reset the app to default settings and delete all your playlists. This action cannot be undone.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final storageService = StorageService();
      await storageService.clearAll();
      
      final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
      playlistProvider.clearAll();
      
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.resetTheme();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All data cleared successfully'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    }
  }
}