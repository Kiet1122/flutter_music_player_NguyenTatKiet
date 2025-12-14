import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;
  
  List<PlaylistModel> _playlists = [];
  bool _isLoading = false;

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => _playlists;
  bool get isLoading => _isLoading;

  Future<void> _loadPlaylists() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _playlists = await _storageService.getPlaylists();
    } catch (e) {
      print('Error loading playlists: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlaylistModel> createPlaylist(String name) async {
    final newPlaylist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _playlists.add(newPlaylist);
    await _savePlaylists();
    notifyListeners();
    
    return newPlaylist;
  }

  Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      
      if (!playlist.songIds.contains(song.id)) {
        final newSongIds = List<String>.from(playlist.songIds)..add(song.id);
        _playlists[index] = playlist.copyWith(
          songIds: newSongIds,
        );
        await _savePlaylists();
        notifyListeners();
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      final newSongIds = List<String>.from(playlist.songIds)..remove(songId);
      _playlists[index] = playlist.copyWith(
        songIds: newSongIds,
      );
      await _savePlaylists();
      notifyListeners();
    }
  }

  Future<void> updatePlaylistName(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      _playlists[index] = playlist.copyWith(
        name: newName,
      );
      await _savePlaylists();
      notifyListeners();
    }
  }

  Future<void> updatePlaylistCover(String playlistId, String? coverImage) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final playlist = _playlists[index];
      _playlists[index] = playlist.copyWith(
        coverImage: coverImage,
      );
      await _savePlaylists();
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await _savePlaylists();
    notifyListeners();
  }

  PlaylistModel? getPlaylistById(String playlistId) {
    return _playlists.firstWhere((p) => p.id == playlistId);
  }

  List<String> getPlaylistSongIds(String playlistId) {
    final playlist = getPlaylistById(playlistId);
    return playlist?.songIds ?? [];
  }

  Future<void> _savePlaylists() async {
    await _storageService.savePlaylists(_playlists);
  }

  Future<void> clearAll() async {
    _playlists.clear();
    await _storageService.clearAll();
    notifyListeners();
  }
}