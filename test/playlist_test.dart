import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playlist_model.dart';

void main() {
  group('PLAYLIST SIMPLE TESTS', () {
    test('PlaylistModel creation', () {
      final now = DateTime.now();
      final playlist = PlaylistModel(
        id: 'test-id',
        name: 'Test Playlist',
        songIds: ['song1', 'song2', 'song3'],
        createdAt: now,
        updatedAt: now,
        coverImage: 'cover.jpg',
      );
      
      expect(playlist.id, 'test-id');
      expect(playlist.name, 'Test Playlist');
      expect(playlist.songIds.length, 3);
      expect(playlist.coverImage, 'cover.jpg');
      expect(playlist.createdAt, now);
      expect(playlist.updatedAt, now);
    });
    
    test('PlaylistModel toJson/fromJson', () {
      final original = PlaylistModel(
        id: 'json-test',
        name: 'JSON Playlist',
        songIds: ['a', 'b', 'c'],
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 16, 14, 45),
        coverImage: 'image.png',
      );
      
      final json = original.toJson();
      expect(json['id'], 'json-test');
      expect(json['name'], 'JSON Playlist');
      expect(json['songIds'], ['a', 'b', 'c']);
      expect(json['coverImage'], 'image.png');
      expect(json['createdAt'], '2024-01-15T10:30:00.000');
      
      final restored = PlaylistModel.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.songIds, original.songIds);
      expect(restored.coverImage, original.coverImage);
    });
    
    test('PlaylistModel copyWith', () {
      final original = PlaylistModel(
        id: 'original',
        name: 'Original Name',
        songIds: ['1', '2'],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      
      final updated = original.copyWith(
        name: 'Updated Name',
        songIds: ['1', '2', '3', '4'],
        coverImage: 'new-cover.jpg',
      );
      
      expect(updated.id, 'original');
      expect(updated.name, 'Updated Name');
      expect(updated.songIds.length, 4);
      expect(updated.coverImage, 'new-cover.jpg');
      expect(updated.createdAt, original.createdAt); 
      expect(updated.updatedAt.isAfter(original.updatedAt), true); 
    });
    
    test('PlaylistModel with null coverImage', () {
      final playlist = PlaylistModel(
        id: 'no-cover',
        name: 'No Cover Playlist',
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        coverImage: null,
      );
      
      expect(playlist.coverImage, isNull);
      
      final json = playlist.toJson();
      expect(json['coverImage'], isNull);
    });
  });
}