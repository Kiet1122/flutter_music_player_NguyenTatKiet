import 'package:media_info/media_info.dart';
import 'package:path/path.dart' as p;

class AudioMetadataExtractor {
  static final MediaInfo _mediaInfo = MediaInfo();

  static Future<Map<String, dynamic>> extractMetadata(String filePath) async {
    try {
      final info = await _mediaInfo.getMediaInfo(filePath);

      final general = info['general'] ?? {};
      final audio = (info['audio'] as List?)?.first ?? {};

      return {
        'title': general['title'] ??
            p.basenameWithoutExtension(filePath),
        'artist': general['performer'] ??
            audio['performer'] ??
            'Unknown Artist',
        'album': general['album'] ?? 'Unknown Album',
        'albumArt': null,
        'duration': _parseDuration(general['duration']),
        'year': general['recorded_date'],
        'genre': general['genre'],
        'trackNumber': general['track_position'],
        'discNumber': general['part_position'],
      };
    } catch (e) {
      print('Error extracting metadata: $e');
      return {
        'title': p.basenameWithoutExtension(filePath),
        'artist': 'Unknown Artist',
        'album': 'Unknown Album',
        'albumArt': null,
        'duration': Duration.zero,
      };
    }
  }

  static Duration _parseDuration(dynamic value) {
    if (value == null) return Duration.zero;

    final ms = double.tryParse(value.toString());
    if (ms == null) return Duration.zero;

    return Duration(milliseconds: ms.round());
  }
}
