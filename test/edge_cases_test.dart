import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/song_model.dart';
import 'package:offline_music_player/providers/music_provider.dart';

void main() {
  group(' EDGE CASES - SIMPLE', () {
    test('1. Empty music library', () {
      final provider = MusicProvider();
      provider.clearSongs();
      expect(provider.allSongs, isEmpty);
    });

    test('2. Long song names', () {
      final provider = MusicProvider();
      final song = SongModel(
        id: '1',
        title: 'A' * 50,
        artist: 'Artist',
        filePath: 'song.mp3',
      );
      
      provider.addSongs([song]);
      expect(provider.allSongs.length, 1);
    });

    test('3. Missing metadata', () {
      final provider = MusicProvider();
      final song = SongModel(
        id: '1',
        title: '',
        artist: '',
        filePath: 'song.mp3',
        album: null,
        duration: null,
      );
      
      provider.addSongs([song]);
      expect(provider.allSongs.first.album, isNull);
    });

    test('4. Search songs', () {
      final provider = MusicProvider();
      final songs = [
        SongModel(id: '1', title: 'Hello', artist: 'A', filePath: '1.mp3'),
        SongModel(id: '2', title: 'World', artist: 'B', filePath: '2.mp3'),
      ];
      
      provider.addSongs(songs);
      
      expect(provider.searchSongs('Hello').length, 1);
      expect(provider.searchSongs('').length, 2);
    });

    test('5. Case insensitive search', () {
      final provider = MusicProvider();
      final song = SongModel(
        id: '1',
        title: 'Test Song',
        artist: 'Artist',
        filePath: 'song.mp3',
      );
      
      provider.addSongs([song]);
      
      expect(provider.searchSongs('TEST').length, 1);
      expect(provider.searchSongs('test').length, 1);
    });

    test('6. Get songs by artist', () {
      final provider = MusicProvider();
      final songs = [
        SongModel(id: '1', title: 'Song 1', artist: 'Artist A', filePath: '1.mp3'),
        SongModel(id: '2', title: 'Song 2', artist: 'Artist A', filePath: '2.mp3'),
        SongModel(id: '3', title: 'Song 3', artist: 'Artist B', filePath: '3.mp3'),
      ];
      
      provider.addSongs(songs);
      
      expect(provider.getSongsByArtist('Artist A').length, 2);
      expect(provider.getSongsByArtist('Artist B').length, 1);
    });

    test('7. Get songs by album', () {
      final provider = MusicProvider();
      final songs = [
        SongModel(id: '1', title: 'Song 1', artist: 'A', album: 'Album 1', filePath: '1.mp3'),
        SongModel(id: '2', title: 'Song 2', artist: 'A', album: 'Album 1', filePath: '2.mp3'),
        SongModel(id: '3', title: 'Song 3', artist: 'A', album: null, filePath: '3.mp3'),
      ];
      
      provider.addSongs(songs);
      
      expect(provider.getSongsByAlbum('Album 1').length, 2);
      expect(provider.getSongsByAlbum('Not Exist').length, 0);
    });

    test('8. Duplicate songs filter', () {
      final provider = MusicProvider();
      final song = SongModel(
        id: 'same',
        title: 'Same Song',
        artist: 'Same Artist',
        filePath: 'same.mp3',
      );
      
      provider.addSongs([song]);
      provider.addSongs([song]);
      provider.addSongs([song]);
      
      expect(provider.allSongs.length, 1);
    });
  });
}