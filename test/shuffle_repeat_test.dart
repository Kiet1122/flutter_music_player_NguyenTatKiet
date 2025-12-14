import 'package:flutter_test/flutter_test.dart';
import 'package:offline_music_player/models/playback_state_model.dart';

void main() {
  group('PLAYBACK STATE MODEL TESTS', () {
    
    test('PlaybackState creation and properties', () {
      final state = PlaybackState(
        position: Duration(minutes: 1, seconds: 23),
        duration: Duration(minutes: 4, seconds: 56),
        isPlaying: true,
      );
      
      expect(state.position.inSeconds, 83); 
      expect(state.duration.inSeconds, 296);
      expect(state.isPlaying, true);
      expect(state.progress, closeTo(83 / 296, 0.001));
    });
    
    test('PlaybackState edge cases', () {
      final state1 = PlaybackState(
        position: Duration(seconds: -10),
        duration: Duration(minutes: 3),
        isPlaying: false,
      );
      expect(state1.position.inSeconds, -10);
      
      final state2 = PlaybackState(
        position: Duration(minutes: 5),
        duration: Duration(minutes: 3),
        isPlaying: true,
      );
      expect(state2.progress, greaterThan(1.0)); 
      
      final state3 = PlaybackState(
        position: Duration.zero,
        duration: Duration.zero,
        isPlaying: false,
      );
      expect(state3.progress, 0.0);
    });
    
    test('PlaybackState equality', () {
      final state1 = PlaybackState(
        position: Duration(seconds: 30),
        duration: Duration(minutes: 2),
        isPlaying: true,
      );
      
      final state2 = PlaybackState(
        position: Duration(seconds: 30),
        duration: Duration(minutes: 2),
        isPlaying: true,
      );
      
      final state3 = PlaybackState(
        position: Duration(seconds: 45),
        duration: Duration(minutes: 2),
        isPlaying: true,
      );
      
      expect(state1.position, state2.position);
      expect(state1.duration, state2.duration);
      expect(state1.isPlaying, state2.isPlaying);
      expect(state1.position, isNot(equals(state3.position)));
    });
    
    test('PlaybackState toString format', () {
      final state = PlaybackState(
        position: Duration(minutes: 1, seconds: 15),
        duration: Duration(minutes: 3, seconds: 45),
        isPlaying: false,
      );
      
      final str = state.toString();
      expect(str, contains('PlaybackState'));
      expect(str, contains('position'));
      expect(str, contains('duration'));
      expect(str, contains('isPlaying'));
      expect(str, contains('false'));
    });
    
    test('Progress calculation precision', () {
      final state1 = PlaybackState(
        position: Duration(milliseconds: 333),
        duration: Duration(milliseconds: 1000),
        isPlaying: true,
      );
      expect(state1.progress, 0.333);
      
      final state2 = PlaybackState(
        position: Duration(milliseconds: 666),
        duration: Duration(milliseconds: 1000),
        isPlaying: true,
      );
      expect(state2.progress, 0.666);
      
      final state3 = PlaybackState(
        position: Duration(hours: 1),
        duration: Duration(hours: 2),
        isPlaying: true,
      );
      expect(state3.progress, 0.5);
    });
  });
}