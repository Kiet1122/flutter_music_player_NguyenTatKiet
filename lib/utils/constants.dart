import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryColor = Color(0xFF1DB954);
  static const Color backgroundColor = Color(0xFF191414);
  static const Color cardColor = Color(0xFF282828);
  static const Color textColor = Colors.white;
  static const Color greyTextColor = Colors.grey;

  static const double screenPadding = 16.0;
  static const double cardPadding = 12.0;
  static const double elementSpacing = 8.0;

  static const double playerHeight = 80.0;
  static const double albumArtSize = 100.0;
  static const double buttonSize = 48.0;
  static const double iconSize = 24.0;

  static const double borderRadius = 8.0;
  static const double albumArtBorderRadius = 8.0;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);

  static const String appName = 'Offline Music Player';
  static const String defaultArtist = 'Unknown Artist';
  static const String defaultAlbum = 'Unknown Album';

  static const List<String> supportedFormats = [
    '.mp3',
    '.m4a',
    '.aac',
    '.wav',
    '.flac',
    '.ogg',
    '.wma',
  ];

  static const double defaultVolume = 1.0;
  static const double defaultSpeed = 1.0;
  static const bool defaultShuffle = false;
  static const int defaultRepeatMode = 0; 

  static const String downloadDirectory = 'Download';
  static const String musicDirectory = 'Music';
  static const String albumArtDirectory = 'album_art';

  static const String playlistsKey = 'playlists';
  static const String lastPlayedKey = 'last_played';
  static const String shuffleKey = 'shuffle_enabled';
  static const String repeatKey = 'repeat_mode';
  static const String volumeKey = 'volume';
  static const String themeKey = 'theme_mode';

  static const String primaryFont = 'Roboto';
  static const String secondaryFont = 'CircularStd';

  static const int maxFileSize = 100 * 1024 * 1024; 
  static const int cacheDuration = 7 * 24 * 60 * 60 * 1000; 

  static const String errorNoPermission = 'Storage permission required';
  static const String errorNoSongs = 'No songs found';
  static const String errorLoadFailed = 'Failed to load songs';
  static const String errorPlaybackFailed = 'Playback failed';

  static const String successPlaylistCreated = 'Playlist created';
  static const String successSongAdded = 'Song added to playlist';
  static const String successCacheCleared = 'Cache cleared';

  static const String homeTitle = 'My Music';
  static const String playlistsTitle = 'Playlists';
  static const String nowPlayingTitle = 'Now Playing';
  static const String settingsTitle = 'Settings';
  static const String allSongsTitle = 'All Songs';

  static const String playButton = 'Play';
  static const String pauseButton = 'Pause';
  static const String nextButton = 'Next';
  static const String previousButton = 'Previous';
  static const String shuffleButton = 'Shuffle';
  static const String repeatButton = 'Repeat';
}