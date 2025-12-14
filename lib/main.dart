import 'package:flutter/material.dart';
import 'package:offline_music_player/providers/music_provider.dart';
import 'package:offline_music_player/screens/recently_played_screen.dart';
import 'package:provider/provider.dart';
import 'package:audio_session/audio_session.dart';
import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/all_songs_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => StorageService()),
        ChangeNotifierProvider(
          create: (context) => PlaylistProvider(context.read<StorageService>()),
        ),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProxyProvider2<
          StorageService,
          PlaylistProvider,
          AudioProvider
        >(
          create: (context) => AudioProvider(
            AudioPlayerService(),
            context.read<StorageService>(),
          ),
          update: (context, storageService, playlistProvider, audioProvider) {
            return audioProvider ??
                AudioProvider(AudioPlayerService(), storageService);
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Offline Music Player',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AllSongsScreen(),
    const RecentlyPlayedScreen(),
    const PlaylistScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Songs'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Recent'),
    BottomNavigationBarItem(
      icon: Icon(Icons.playlist_play),
      label: 'Playlists',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: _navItems,
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF1DB954),
            unselectedItemColor: Colors.grey,
            backgroundColor: const Color(0xFF191414),
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
