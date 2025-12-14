import 'package:flutter/material.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart'; 
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart' as file_scanner;
import '../widgets/song_tile.dart';

class AllSongsScreen extends StatefulWidget {
  const AllSongsScreen({super.key});

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final file_scanner.FileScannerService _fileScannerService = file_scanner.FileScannerService();
  
  List<SongModel> _filteredSongs = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'title';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    print('INIT AllSongsScreen');
    _loadSongsFromProvider();
  }

  void _loadSongsFromProvider() {
    print('Loading songs from MusicProvider');
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    
    if (musicProvider.isInitialized && musicProvider.allSongs.isNotEmpty) {
      print('Using existing songs from provider: ${musicProvider.allSongs.length}');
      _sortSongs(musicProvider.allSongs);
      setState(() {
        _filteredSongs = musicProvider.allSongs;
      });
    } else {
      print('No songs in provider, scanning...');
      _loadSongs();
    }
  }

  Future<void> _loadSongs() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      
      if (musicProvider.allSongs.isNotEmpty) {
        print('Using provider songs: ${musicProvider.allSongs.length}');
        _sortSongs(musicProvider.allSongs);
        setState(() {
          _filteredSongs = musicProvider.allSongs;
          _isLoading = false;
        });
        return;
      }
      
      print('Scanning for songs...');
      final songs = await _fileScannerService.scanAccessibleDirectories();
      print('Found ${songs.length} songs');
      
      musicProvider.setAllSongs(songs);
      
      _sortSongs(songs);
      setState(() {
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading songs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortSongs(List<SongModel> songs) {
    songs.sort((a, b) {
      int comparison = 0;
      
      switch (_sortBy) {
        case 'title':
          comparison = a.title.compareTo(b.title);
          break;
        case 'artist':
          comparison = a.artist.compareTo(b.artist);
          break;
        case 'album':
          comparison = (a.album ?? '').compareTo(b.album ?? '');
          break;
        case 'duration':
          final durationA = a.duration?.inSeconds ?? 0;
          final durationB = b.duration?.inSeconds ?? 0;
          comparison = durationA.compareTo(durationB);
          break;
      }
      
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _applySort(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = true;
      }
      _sortSongs(_filteredSongs);
    });
  }

  void _filterSongs(String query) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSongs = List.from(musicProvider.allSongs);
        _sortSongs(_filteredSongs);
      } else {
        _filteredSongs = musicProvider.searchSongs(query);
        _sortSongs(_filteredSongs);
      }
    });
  }

  Future<void> _refreshSongs() async {
    setState(() {
      _isLoading = true;
    });
    
    await _loadSongs();
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort, color: Colors.white),
      onSelected: _applySort,
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            value: 'title',
            child: Text('Sort by Title'),
          ),
          const PopupMenuItem<String>(
            value: 'artist',
            child: Text('Sort by Artist'),
          ),
          const PopupMenuItem<String>(
            value: 'album',
            child: Text('Sort by Album'),
          ),
          const PopupMenuItem<String>(
            value: 'duration',
            child: Text('Sort by Duration'),
          ),
        ];
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Songs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refreshSongs,
                    tooltip: 'Refresh',
                  ),
                  _buildSortMenu(),
                ],
              ),
            ],
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
                hintText: 'Search songs...',
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
    );
  }

  Widget _buildSongList() {
    if (_filteredSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.music_note,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty ? 'No results found' : 'No songs found',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add some music from the Home screen',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (!_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: _refreshSongs,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredSongs.length,
      itemBuilder: (context, index) {
        final song = _filteredSongs[index];
        return SongTile(
          song: song,
          onTap: () {
            final musicProvider = Provider.of<MusicProvider>(context, listen: false);
            final playlistIndex = musicProvider.allSongs.indexWhere((s) => s.id == song.id);
            if (playlistIndex != -1) {
              final audioProvider = Provider.of<AudioProvider>(context, listen: false);
              audioProvider.setPlaylist(musicProvider.allSongs, playlistIndex);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD AllSongsScreen - Songs: ${_filteredSongs.length}');
    
    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1DB954),
                      ),
                    )
                  : _buildSongList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          return FloatingActionButton(
            backgroundColor: const Color(0xFF1DB954),
            foregroundColor: Colors.white,
            onPressed: () async {
              try {
                setState(() {
                  _isLoading = true;
                });
                
                final newSongs = await _fileScannerService.pickAudioFiles();
                if (newSongs.isNotEmpty) {
                  musicProvider.addSongs(newSongs);
                  
                  setState(() {
                    _filteredSongs = musicProvider.allSongs;
                    _sortSongs(_filteredSongs);
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${newSongs.length} new songs'),
                      backgroundColor: const Color(0xFF1DB954),
                    ),
                  );
                }
              } catch (e) {
                print('Error: $e');
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}