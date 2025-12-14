import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/music_provider.dart';

void main() {
  group('1. PLAYBACK TESTING - FIXED', () {
    test('1.1 - Playlist creation and song management', () {
      final provider = MusicProvider();
      final songs = [
        SongModel(id: '1', title: 'MP3 Song One', artist: 'Artist A', filePath: '1.mp3'),
        SongModel(id: '2', title: 'MP3 Song Two', artist: 'Artist B', filePath: '2.mp3'),
        SongModel(id: '3', title: 'FLAC Song', artist: 'Artist C', filePath: '3.flac'),
        SongModel(id: '4', title: 'M4A Song', artist: 'Artist D', filePath: '4.m4a'),
      ];
      
      provider.addSongs(songs);
      expect(provider.allSongs.length, 4);
      
      expect(provider.searchSongs('MP3').length, 2); 
      expect(provider.searchSongs('FLAC').length, 1);
      expect(provider.searchSongs('M4A').length, 1);
    });
    
    test('1.2 - Song ordering and access', () {
      final provider = MusicProvider();
      final songs = [
        SongModel(id: 'a', title: 'Alpha Song', artist: 'Band X', filePath: 'a.mp3'),
        SongModel(id: 'b', title: 'Beta Song', artist: 'Band Y', filePath: 'b.mp3'),
        SongModel(id: 'c', title: 'Gamma Song', artist: 'Band Z', filePath: 'c.mp3'),
      ];
      
      provider.addSongs(songs);
      
      expect(provider.allSongs[0].title, 'Alpha Song');
      expect(provider.allSongs[1].title, 'Beta Song');
      expect(provider.allSongs[2].title, 'Gamma Song');
      
      expect(provider.searchSongs('Alpha').length, 1);
      expect(provider.searchSongs('Song').length, 3); 
      expect(provider.searchSongs('Band').length, 3); 
    });

    test('1.3 - Different audio format simulation', () {
      final songs = [
        SongModel(id: 'mp3-1', title: 'Rock Song [MP3]', artist: 'Rock Band', filePath: 'rock.mp3'),
        SongModel(id: 'flac-1', title: 'Jazz Song [FLAC]', artist: 'Jazz Band', filePath: 'jazz.flac'),
        SongModel(id: 'm4a-1', title: 'Pop Song [M4A]', artist: 'Pop Band', filePath: 'pop.m4a'),
        SongModel(id: 'wav-1', title: 'Classical Song [WAV]', artist: 'Orchestra', filePath: 'classical.wav'),
      ];
      
      final provider = MusicProvider();
      provider.addSongs(songs);
      
      expect(provider.allSongs.length, 4);
      expect(provider.searchSongs('[MP3]').length, 1);
      expect(provider.searchSongs('[FLAC]').length, 1);
      expect(provider.searchSongs('[M4A]').length, 1);
      expect(provider.searchSongs('[WAV]').length, 1);
    });

    test('1.4 - Song duration and metadata', () {
      final songs = [
        SongModel(
          id: 'long',
          title: 'Long Song',
          artist: 'Artist',
          filePath: 'long.mp3',
          duration: Duration(minutes: 10, seconds: 30),
          filesize: 1024 * 1024 * 15, 
        ),
        SongModel(
          id: 'short',
          title: 'Short Song',
          artist: 'Artist',
          filePath: 'short.mp3',
          duration: Duration(minutes: 2),
          filesize: 1024 * 1024 * 3, 
        ),
      ];
      
      final provider = MusicProvider();
      provider.addSongs(songs);
      
      expect(provider.allSongs[0].duration?.inMinutes, 10);
      expect(provider.allSongs[0].duration?.inSeconds, 630);
      expect(provider.allSongs[1].duration?.inMinutes, 2);
    });

    test('1.5 - Empty search results', () {
      final provider = MusicProvider();
      final songs = [
        SongModel(id: '1', title: 'Test Song', artist: 'Test Artist', filePath: 'test.mp3'),
      ];
      
      provider.addSongs(songs);
      
      expect(provider.searchSongs('NonExistent').length, 0);
      expect(provider.searchSongs('XYZ').length, 0);
      
      expect(provider.searchSongs('').length, 1);
    });
  });
}