import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/music_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/permission_service.dart';
import '../services/playlist_service.dart' as file_scanner;
import '../providers/audio_provider.dart';
import '../widgets/mini_player.dart';
import '../models/song_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final file_scanner.FileScannerService _fileScannerService =
      file_scanner.FileScannerService();
  final PermissionService _permissionService = PermissionService();

  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    print('INIT HomeScreen');
    _initializeApp();
    _showFirstTimeInstructions();
  }

  Future<void> _initializeApp() async {
    print('START _initializeApp');

    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    if (musicProvider.allSongs.isNotEmpty) {
      print(
        'Using existing songs from MusicProvider: ${musicProvider.allSongs.length}',
      );
      setState(() {
        _songs = musicProvider.allSongs;
        _filteredSongs = musicProvider.allSongs;
        _isLoading = false;
      });
      return;
    }

    final storageStatus = await Permission.storage.status;
    final audioStatus = await Permission.audio.status;

    print('Storage status: $storageStatus');
    print('Audio status: $audioStatus');

    _hasPermission = storageStatus.isGranted || audioStatus.isGranted;
    print('Current permission: $_hasPermission');

    if (_hasPermission) {
      print('Permission granted, loading songs...');
      await _loadSongs();
    } else {
      print('No permission, showing permission screen');
    }

    setState(() {
      _isLoading = false;
    });

    print('END _initializeApp');
  }

  Future<void> _showFirstTimeInstructions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownInstructions =
        prefs.getBool('has_shown_instructions') ?? false;

    if (!hasShownInstructions && _hasPermission) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF282828),
              title: const Text(
                'Welcome to Offline Music Player',
                style: TextStyle(color: Colors.white),
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to use:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1. Tap "+" to add music files',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '2. Tap any song to play',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '3. Use search to find songs',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Note: App needs storage permission to scan existing music.',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('has_shown_instructions', true);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Got it!',
                    style: TextStyle(color: Color(0xFF1DB954)),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<void> _loadSongs() async {
    try {
      print('Loading songs...');
      final songs = await _fileScannerService.scanAccessibleDirectories();
      print('Found ${songs.length} songs');

      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.setAllSongs(songs);

      if (mounted) {
        setState(() {
          _songs = songs;
          _filteredSongs = songs;
        });
      }
    } catch (e) {
      print('Error loading songs: $e');
    }
  }

  Future<void> _refreshSongs() async {
    print('Refreshing songs...');
    setState(() {
      _isLoading = true;
    });

    await _loadSongs();

    setState(() {
      _isLoading = false;
    });
  }

  void _filterSongs(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSongs = _songs;
      } else {
        _filteredSongs = _songs.where((song) {
          return song.title.toLowerCase().contains(query.toLowerCase()) ||
              song.artist.toLowerCase().contains(query.toLowerCase()) ||
              (song.album?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'All') {
        _filteredSongs = _songs;
      } else if (filter == 'Artists') {
        final Map<String, SongModel> artistMap = {};
        for (var song in _songs) {
          if (!artistMap.containsKey(song.artist)) {
            artistMap[song.artist] = song;
          }
        }
        _filteredSongs = artistMap.values.toList();
      } else if (filter == 'Albums') {
        final Map<String, SongModel> albumMap = {};
        for (var song in _songs) {
          if (song.album != null && !albumMap.containsKey(song.album)) {
            albumMap[song.album!] = song;
          }
        }
        _filteredSongs = albumMap.values.toList();
      }
    });
  }

  Future<void> _showAddMusicDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF282828),
          title: const Text('Add Music', style: TextStyle(color: Colors.white)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose how to add music:',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'Pick Files: Select audio files directly',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 5),
              Text(
                'Scan All: Find music in accessible folders',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _addFromFilePicker(context);
              },
              child: const Text('Pick Audio Files'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _scanAllDirectories(context);
              },
              child: const Text('Scan All Folders'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFromFilePicker(BuildContext context) async {
    print('START _addFromFilePicker');

    final BuildContext localContext = context;

    try {
      if (!mounted) {
        print('Widget not mounted, skipping');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final newSongs = await _fileScannerService.pickAudioFiles();
      print('Got ${newSongs.length} new songs');

      if (!mounted) {
        print('Widget not mounted after async, skipping');
        return;
      }

      if (newSongs.isNotEmpty) {
        final updatedSongs = List<SongModel>.from(_songs);
        updatedSongs.addAll(newSongs);

        setState(() {
          _songs = updatedSongs;
          _filteredSongs = List.from(updatedSongs);
        });

        if (localContext.mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            SnackBar(
              content: Text(
                'Added ${newSongs.length} new ${newSongs.length == 1 ? 'song' : 'songs'}',
              ),
              backgroundColor: const Color(0xFF1DB954),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (!_hasPermission) {
          print('Auto-granting permission after adding files');
          setState(() {
            _hasPermission = true;
          });
        }
      } else {
        if (localContext.mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            const SnackBar(
              content: Text('No audio files selected'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error adding songs: $e');

      if (mounted && localContext.mounted) {
        ScaffoldMessenger.of(localContext).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().split('\n').first}',
            ), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    print('END _addFromFilePicker');
  }

  Future<void> _scanAllDirectories(BuildContext context) async {
    print('START _scanAllDirectories');

    final BuildContext localContext = context;

    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final newSongs = await _fileScannerService.scanAccessibleDirectories();
      print('Found ${newSongs.length} total songs');

      if (!mounted) return;

      if (newSongs.isNotEmpty) {
        setState(() {
          _songs = newSongs;
          _filteredSongs = newSongs;
        });

        if (localContext.mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            SnackBar(
              content: Text('Found ${newSongs.length} songs'),
              backgroundColor: const Color(0xFF1DB954),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (!_hasPermission) {
          print('Auto-granting permission after scanning');
          setState(() {
            _hasPermission = true;
          });
        }
      } else {
        if (localContext.mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            const SnackBar(
              content: Text('No songs found in accessible folders'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error scanning: $e');

      if (mounted && localContext.mounted) {
        ScaffoldMessenger.of(localContext).showSnackBar(
          SnackBar(
            content: Text(
              'Error scanning: ${e.toString().split('\n').first}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    print('END _scanAllDirectories');
  }

  Future<void> _requestPermissions() async {
    print('START _requestPermissions');

    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      final granted = await _permissionService.requestStoragePermission();
      print('Permission granted: $granted');

      if (!mounted) return;

      if (granted) {
        setState(() {
          _hasPermission = true;
        });

        await _loadSongs();

        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission granted'),
              backgroundColor: Color(0xFF1DB954),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error requesting permission: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    print('END _requestPermissions');
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
                'My Music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  if (_hasPermission) 
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _refreshSongs,
                      tooltip: 'Refresh',
                    ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      if (_songs.isNotEmpty) {
                        showSearch(
                          context: context,
                          delegate: _MusicSearchDelegate(_songs, context),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No songs to search'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),

          if (_hasPermission &&
              _songs
                  .isNotEmpty) 
            Column(
              children: [
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Artists', 'Albums'].map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (_) => _applyFilter(filter),
                          backgroundColor: const Color(0xFF282828),
                          selectedColor: const Color(0xFF1DB954),
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    if (_filteredSongs.isEmpty) {
      return _buildNoSongs();
    }

    return ListView.builder(
      itemCount: _filteredSongs.length,
      itemBuilder: (context, index) {
        final song = _filteredSongs[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.music_note,
                color: Color(0xFF1DB954),
                size: 30,
              ),
            ),
            title: Text(
              song.title.length > 30
                  ? '${song.title.substring(0, 30)}...'
                  : song.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow, color: Color(0xFF1DB954)),
              onPressed: () {
                final playlistIndex = _songs.indexWhere((s) => s.id == song.id);
                if (playlistIndex != -1) {
                  context.read<AudioProvider>().setPlaylist(
                    _songs,
                    playlistIndex,
                  );
                }
              },
            ),
            onTap: () {
              final playlistIndex = _songs.indexWhere((s) => s.id == song.id);
              if (playlistIndex != -1) {
                context.read<AudioProvider>().setPlaylist(
                  _songs,
                  playlistIndex,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildPermissionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 100, color: Color(0xFF1DB954)),
            const SizedBox(height: 30),
            const Text(
              'Welcome to Music Player',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'To play your music, you can:',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            Card(
              color: const Color(0xFF282828),
              child: ListTile(
                leading: const Icon(
                  Icons.add,
                  color: Color(0xFF1DB954),
                  size: 30,
                ),
                title: const Text(
                  'Add Music Files',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Select audio files directly from your device',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: () => _showAddMusicDialog(context),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              color: const Color(0xFF282828),
              child: ListTile(
                leading: const Icon(
                  Icons.folder_open,
                  color: Color(0xFF1DB954),
                  size: 30,
                ),
                title: const Text(
                  'Scan Music Folders',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Grant permission to scan existing music files',
                  style: TextStyle(color: Colors.grey),
                ),
                onTap: _requestPermissions,
              ),
            ),

            const SizedBox(height: 30),

            TextButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text(
                'Or open settings to grant permission manually',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 20),
            const Text(
              'No Songs Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add some music to get started',
              style: TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () => _showAddMusicDialog(context),
              child: const Text('Add Music'),
            ),
            const SizedBox(height: 15),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1DB954),
                side: const BorderSide(color: Color(0xFF1DB954)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: _requestPermissions,
              child: const Text('Scan Existing Music'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD HomeScreen');
    print('📊 Songs: ${_songs.length}, Filtered: ${_filteredSongs.length}');
    print('⏳ Loading: $_isLoading, Permission: $_hasPermission');

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF1DB954)),
                          SizedBox(height: 20),
                          Text(
                            'Loading...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : _hasPermission
                  ? (_songs.isEmpty ? _buildNoSongs() : _buildSongList())
                  : _buildPermissionScreen(),
            ),

            Consumer<AudioProvider>(
              builder: (context, provider, child) {
                if (provider.currentSong == null)
                  return const SizedBox.shrink();
                return const MiniPlayer();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicSearchDelegate extends SearchDelegate {
  final List<SongModel> songs;
  final BuildContext context;

  _MusicSearchDelegate(this.songs, this.context);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = songs.where((song) {
      return song.title.toLowerCase().contains(query.toLowerCase()) ||
          song.artist.toLowerCase().contains(query.toLowerCase()) ||
          (song.album?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    return _buildResultsList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? songs.take(10).toList()
        : songs.where((song) {
            return song.title.toLowerCase().contains(query.toLowerCase()) ||
                song.artist.toLowerCase().contains(query.toLowerCase());
          }).toList();

    return _buildResultsList(suggestions);
  }

  Widget _buildResultsList(List<SongModel> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'No songs found for "$query"',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.music_note, color: Colors.grey),
          ),
          title: Text(
            song.title,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist,
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            final playlistIndex = songs.indexWhere((s) => s.id == song.id);
            if (playlistIndex != -1) {
              context.read<AudioProvider>().setPlaylist(songs, playlistIndex);
            }
            close(context, null);
          },
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF191414),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF191414),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }
}
