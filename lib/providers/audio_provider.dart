import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;

  AudioProvider(this._audioService, this._storageService) {
    _init().catchError((error) {
      print('Error initializing AudioProvider: $error');
    });
  }

  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<PlaybackState> get playbackStateStream =>
      _audioService.playbackStateStream;

  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatMode = await _storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatMode];
    await _audioService.setLoopMode(_loopMode);

    final volume = await _storageService.getVolume();
    await _audioService.setVolume(volume);
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> addToPlaylist(List<SongModel> songs) async {
    _playlist.addAll(songs);
    notifyListeners();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) {
      print('Invalid index: $index');
      return;
    }

    _currentIndex = index;
    final song = _playlist[index];

    try {
      print('Loading song: ${song.title}');
      await _audioService.loadAudio(song.filePath);

      final lastPosition = await _storageService.getLastPosition(song.id);
      if (lastPosition != null) {
        await _audioService.seek(lastPosition);
      }

      await _storageService.saveLastPlayed(song.id);
      await _audioService.play();

      print('Song playing successfully');
    } catch (e) {
      print('Error playing song: $e');
      if (_playlist.length > 1) {
        await next();
      }
    }

    notifyListeners();
  }

  Future<void> playPause() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      if (currentSong == null && _playlist.isNotEmpty) {
        await _playSongAtIndex(0);
      } else {
        await _audioService.play();
      }
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    int newIndex;
    if (_isShuffleEnabled) {
      newIndex = _getRandomIndex();
    } else {
      newIndex = (_currentIndex + 1) % _playlist.length;
    }

    await _playSongAtIndex(newIndex);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
    } else {
      int newIndex;
      if (_isShuffleEnabled) {
        newIndex = _getRandomIndex();
      } else {
        newIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }
      await _playSongAtIndex(newIndex);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    if (currentSong != null) {
      await _storageService.saveLastPosition(currentSong!.id, position);
    }
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }

    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
    await _storageService.saveVolume(volume);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
    notifyListeners();
  }

  int _getRandomIndex() {
    if (_playlist.isEmpty) return 0;

    int randomIndex;
    do {
      randomIndex = DateTime.now().millisecondsSinceEpoch % _playlist.length;
    } while (randomIndex == _currentIndex && _playlist.length > 1);

    return randomIndex;
  }

  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
    _audioService.stop();
    notifyListeners();
  }

  void removeSong(int index) {
    if (index >= 0 && index < _playlist.length) {
      if (index == _currentIndex) {
        next();
      }
      _playlist.removeAt(index);
      if (_currentIndex >= _playlist.length) {
        _currentIndex = _playlist.isNotEmpty ? _playlist.length - 1 : 0;
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
