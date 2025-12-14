import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';

class RecentlyPlayedService {
  static const String _recentKey = 'recently_played';
  static const int _maxRecent = 20;

  Future<void> addToRecentlyPlayed(SongModel song) async {
    final prefs = await SharedPreferences.getInstance();
    final recentString = prefs.getString(_recentKey);
    List<Map<String, dynamic>> recentList = [];

    if (recentString != null) {
      try {
        final List<dynamic> jsonList = json.decode(recentString);
        recentList = jsonList.cast<Map<String, dynamic>>();
      } catch (e) {
        print('Error parsing recently played: $e');
      }
    }

    recentList.removeWhere((item) => item['id'] == song.id);
    
    recentList.insert(0, song.toJson());
    
    if (recentList.length > _maxRecent) {
      recentList = recentList.sublist(0, _maxRecent);
    }

    await prefs.setString(_recentKey, json.encode(recentList));
  }

  Future<List<SongModel>> getRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final recentString = prefs.getString(_recentKey);

    if (recentString != null) {
      try {
        final List<dynamic> jsonList = json.decode(recentString);
        return jsonList.map((json) => SongModel.fromJson(json)).toList();
      } catch (e) {
        print('Error loading recently played: $e');
      }
    }

    return [];
  }

  Future<void> clearRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentKey);
  }
}