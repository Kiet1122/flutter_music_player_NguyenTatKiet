import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/audio_provider.dart';
import '../services/recently_played_service.dart';
import '../widgets/song_tile.dart';

class RecentlyPlayedScreen extends StatefulWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  State<RecentlyPlayedScreen> createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen> {
  final RecentlyPlayedService _recentService = RecentlyPlayedService();
  List<SongModel> _recentSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentlyPlayed();
  }

  Future<void> _loadRecentlyPlayed() async {
    try {
      final songs = await _recentService.getRecentlyPlayed();
      setState(() {
        _recentSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading recently played: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearRecentlyPlayed() async {
    await _recentService.clearRecentlyPlayed();
    setState(() {
      _recentSongs.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recently played cleared'),
        backgroundColor: Color(0xFF1DB954),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Recently Played',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Play some songs to see them here',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Browse Songs'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Recently Played'),
        actions: [
          if (_recentSongs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearRecentlyPlayed,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1DB954),
              ),
            )
          : _recentSongs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _recentSongs.length,
                  itemBuilder: (context, index) {
                    final song = _recentSongs[index];
                    return SongTile(
                      song: song,
                      onTap: () {
                        final musicProvider = Provider.of<MusicProvider>(context, listen: false);
                        final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                        
                        final allSongs = musicProvider.allSongs;
                        final playlistIndex = allSongs.indexWhere((s) => s.id == song.id);
                        
                        if (playlistIndex != -1) {
                          audioProvider.setPlaylist(allSongs, playlistIndex);
                          _recentService.addToRecentlyPlayed(song);
                        }
                      },
                    );
                  },
                ),
    );
  }
}