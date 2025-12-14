import 'package:flutter/material.dart';
import '../models/song_model.dart';

class MusicProvider extends ChangeNotifier {
  List<SongModel> _allSongs = [];
  bool _isInitialized = false;

  List<SongModel> get allSongs => _allSongs;
  bool get isInitialized => _isInitialized;

  void addSongs(List<SongModel> newSongs) {
    final existingPaths = _allSongs.map((s) => s.filePath).toSet();
    final uniqueNewSongs = newSongs.where((song) => !existingPaths.contains(song.filePath)).toList();
    
    _allSongs.addAll(uniqueNewSongs);
    notifyListeners();
    print('MusicProvider: Added ${uniqueNewSongs.length} songs, total: ${_allSongs.length}');
  }

  void setAllSongs(List<SongModel> songs) {
    _allSongs = songs;
    _isInitialized = true;
    notifyListeners();
    print('MusicProvider: Set ${songs.length} songs');
  }

  void clearSongs() {
    _allSongs.clear();
    notifyListeners();
  }

  List<SongModel> searchSongs(String query) {
    if (query.isEmpty) return _allSongs;
    
    final lowerQuery = query.toLowerCase();
    return _allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
             song.artist.toLowerCase().contains(lowerQuery) ||
             (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<SongModel> getSongsByArtist(String artist) {
    return _allSongs.where((song) => song.artist == artist).toList();
  }

  List<SongModel> getSongsByAlbum(String album) {
    return _allSongs.where((song) => song.album == album).toList();
  }
}