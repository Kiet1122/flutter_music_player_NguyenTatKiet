import 'dart:io';

import 'package:offline_music_player/utils/audio_metadata_extractor.dart';

class SongModel {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration? duration;
  final String? albumArt;
  final int? filesize;
  final DateTime? dateAdded; 
  final int? trackNumber;
  final int? year;
  final String? genre;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.duration,
    this.albumArt,
    this.filesize,
    this.dateAdded, 
    this.trackNumber,
    this.year,
    this.genre,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? 'Unknown Artist',
      album: json['album'],
      filePath: json['filePath'] ?? '',
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      albumArt: json['albumArt'],
      filesize: json['filesize'],
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'])
          : null,
      trackNumber: json['trackNumber'],
      year: json['year'],
      genre: json['genre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'albumArt': albumArt,
      'filesize': filesize,
      'dateAdded': dateAdded?.toIso8601String(), 
      'trackNumber': trackNumber,
      'year': year,
      'genre': genre,
    };
  }

  static Future<SongModel> fromAudioFile(File file) async {
    final metadata = await AudioMetadataExtractor.extractMetadata(file.path);
    final stat = await file.stat();
    
    return SongModel(
      id: file.path.hashCode.toString(),
      title: metadata['title'] as String,
      artist: metadata['artist'] as String,
      album: metadata['album'] as String?,
      filePath: file.path,
      duration: metadata['duration'] as Duration?,
      albumArt: metadata['albumArt'] as String?,
      filesize: stat.size,
      dateAdded: DateTime.now(), 
      trackNumber: metadata['trackNumber'] as int?,
      year: metadata['year'] as int?,
      genre: metadata['genre'] as String?,
    );
  }
}