import 'package:flutter/material.dart';
import 'package:offline_music_player/widgets/song_tile.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/playlist_service.dart' as file_scanner;
import '../widgets/playlist_card.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final file_scanner.FileScannerService _fileScannerService = file_scanner.FileScannerService();
  
  List<SongModel> _allSongs = [];
  bool _isLoadingSongs = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllSongs();
  }

  Future<void> _loadAllSongs() async {
    setState(() {
      _isLoadingSongs = true;
    });
    
    try {
      final songs = await _fileScannerService.scanDownloadDirectory();
      setState(() {
        _allSongs = songs;
      });
    } catch (e) {
      print('Error loading songs: $e');
    } finally {
      setState(() {
        _isLoadingSongs = false;
      });
    }
  }

  Future<void> _createNewPlaylist(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Create New Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter playlist name',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
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
                backgroundColor: const Color(0xFF1DB954),
              ),
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
                  await playlistProvider.createPlaylist(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistOptions(BuildContext context, PlaylistModel playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Rename Playlist',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _renamePlaylist(context, playlist);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Playlist',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deletePlaylist(context, playlist);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _renamePlaylist(BuildContext context, PlaylistModel playlist) async {
    final TextEditingController controller = TextEditingController(text: playlist.name);
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Rename Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new name',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF1DB954)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
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
                backgroundColor: const Color(0xFF1DB954),
              ),
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
                  await playlistProvider.updatePlaylistName(playlist.id, controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePlaylist(BuildContext context, PlaylistModel playlist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Delete Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${playlist.name}"?',
            style: const TextStyle(color: Colors.grey),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
      await playlistProvider.deletePlaylist(playlist.id);
    }
  }

  void _viewPlaylistDetails(BuildContext context, PlaylistModel playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PlaylistDetailsScreen(playlist: playlist),
      ),
    );
  }

  Widget _buildPlaylistGrid(List<PlaylistModel> playlists) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.playlist_add, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'No Playlists',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create your first playlist to organize your music',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () => _createNewPlaylist(context),
              child: const Text('Create Playlist'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      padding: const EdgeInsets.all(16),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return PlaylistCard(
          playlist: playlist,
          onTap: () => _viewPlaylistDetails(context, playlist),
          onLongPress: () => _showPlaylistOptions(context, playlist),
        );
      },
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
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewPlaylist(context),
            tooltip: 'Create New Playlist',
          ),
        ],
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          if (playlistProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1DB954),
              ),
            );
          }

          return _buildPlaylistGrid(playlistProvider.playlists);
        },
      ),
    );
  }
}

class _PlaylistDetailsScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const _PlaylistDetailsScreen({required this.playlist});

  @override
  State<_PlaylistDetailsScreen> createState() => _PlaylistDetailsScreenState();
}

class _PlaylistDetailsScreenState extends State<_PlaylistDetailsScreen> {
  final file_scanner.FileScannerService _fileScannerService = file_scanner.FileScannerService();
  
  List<SongModel> _allSongs = [];
  List<SongModel> _playlistSongs = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPlaylistSongs();
  }

  Future<void> _loadPlaylistSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allSongs = await _fileScannerService.scanDownloadDirectory();
      setState(() {
        _allSongs = allSongs;
      });

      final playlistSongIds = widget.playlist.songIds;
      final playlistSongs = allSongs.where((song) => playlistSongIds.contains(song.id)).toList();
      
      setState(() {
        _playlistSongs = playlistSongs;
      });
    } catch (e) {
      print('Error loading playlist songs: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addSongsToPlaylist() async {
    final List<SongModel> availableSongs = _allSongs.where((song) {
      return !widget.playlist.songIds.contains(song.id);
    }).toList();

    if (availableSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All songs are already in this playlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final List<SongModel>? selectedSongs = await showDialog<List<SongModel>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Add Songs to Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: availableSongs.length,
              itemBuilder: (context, index) {
                final song = availableSongs[index];
                return CheckboxListTile(
                  value: false,
                  onChanged: (value) {
                  },
                  title: Text(
                    song.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
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
                backgroundColor: const Color(0xFF1DB954),
              ),
              onPressed: () {
                Navigator.pop(context, availableSongs.take(5).toList());
              },
              child: const Text('Add Selected'),
            ),
          ],
        );
      },
    );

    if (selectedSongs != null && selectedSongs.isNotEmpty) {
      final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
      for (final song in selectedSongs) {
        await playlistProvider.addSongToPlaylist(widget.playlist.id, song);
      }
      
      await _loadPlaylistSongs();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${selectedSongs.length} songs to playlist'),
          backgroundColor: const Color(0xFF1DB954),
        ),
      );
    }
  }

  Future<void> _removeSongFromPlaylist(SongModel song) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text(
            'Remove Song',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Remove "${song.title}" from playlist?',
            style: const TextStyle(color: Colors.grey),
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
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
      await playlistProvider.removeSongFromPlaylist(widget.playlist.id, song.id);
      
      setState(() {
        _playlistSongs.removeWhere((s) => s.id == song.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Song removed from playlist'),
          backgroundColor: const Color(0xFF1DB954),
        ),
      );
    }
  }

  void _playPlaylist(BuildContext context) {
    if (_playlistSongs.isNotEmpty) {
      final audioProvider = Provider.of<AudioProvider>(context, listen: false);
      audioProvider.setPlaylist(_playlistSongs, 0);
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<SongModel> get _filteredSongs {
    if (_searchQuery.isEmpty) {
      return _playlistSongs;
    }
    
    return _playlistSongs.where((song) {
      return song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             song.artist.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _playPlaylist(context),
            tooltip: 'Play Playlist',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSongsToPlaylist,
            tooltip: 'Add Songs',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1DB954),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_playlistSongs.length} songs',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF282828),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          onChanged: _filterSongs,
                          decoration: InputDecoration(
                            hintText: 'Search in playlist...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _playlistSongs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_off, size: 80, color: Colors.grey),
                              const SizedBox(height: 20),
                              const Text(
                                'No songs in playlist',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Add some songs to get started',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1DB954),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                ),
                                onPressed: _addSongsToPlaylist,
                                child: const Text('Add Songs'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = _filteredSongs[index];
                            return SongTile(
                              song: song,
                              onTap: () {
                                final playlistIndex = _playlistSongs.indexWhere((s) => s.id == song.id);
                                if (playlistIndex != -1) {
                                  final audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                  audioProvider.setPlaylist(_playlistSongs, playlistIndex);
                                }
                              },
                              onOptionsPressed: () => _removeSongFromPlaylist(song),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}