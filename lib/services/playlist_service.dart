import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/song_model.dart';

class FileScannerService {
  static final List<String> supportedFormats = [
    '.mp3',
    '.m4a',
    '.aac',
    '.wav',
    '.flac',
    '.ogg',
    '.wma',
  ];

  Future<List<SongModel>> scanDownloadDirectory() async {
    try {
      final Directory? externalDir = await getExternalStorageDirectory();

      if (externalDir == null) {
        throw Exception('Không tìm thấy thư mục storage');
      }

      final List<String> possiblePaths = [
        '${externalDir.path}/Download',
        '${externalDir.path}/Downloads',
        '${externalDir.path}/Music',
        '${externalDir.path}/Documents',
        '${externalDir.path}/DCIM',
        externalDir.path,
      ];

      for (final path in possiblePaths) {
        final Directory dir = Directory(path);
        if (await dir.exists()) {
          print('Scanning directory: $path');
          return await _scanDirectory(dir);
        }
      }

      throw Exception('Không tìm thấy thư mục nhạc');
    } catch (e) {
      throw Exception('Lỗi khi quét thư mục: $e');
    }
  }

  Future<List<SongModel>> scanDocumentDirectory() async {
    try {
      final Directory? documentsDir = await getExternalStorageDirectory();

      if (documentsDir == null) {
        throw Exception('Không tìm thấy thư mục Documents');
      }

      return await _scanDirectory(documentsDir);
    } catch (e) {
      throw Exception('Lỗi khi quét thư mục Documents: $e');
    }
  }

  Future<List<SongModel>> pickAudioFiles() async {
    try {
      print('=== START pickAudioFiles ===');

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.audio,
        allowCompression: false,
      );

      print('FilePicker result: ${result?.files.length} files');

      if (result != null && result.files.isNotEmpty) {
        List<SongModel> songs = [];

        for (var platformFile in result.files) {
          print('Processing file: ${platformFile.path}');

          if (platformFile.path != null) {
            final File cachedFile = File(platformFile.path!);

            final cachedExists = await cachedFile.exists();
            print('Cached file exists: $cachedExists');

            if (cachedExists && _isAudioFile(cachedFile)) {
              try {
                final permanentFile = await _copyToPermanentDirectory(
                  cachedFile,
                );
                print('Copied to permanent: ${permanentFile.path}');

                final song = await _createSongModel(permanentFile);
                songs.add(song);
                print('Song added: ${song.title} - ${song.artist}');
              } catch (e) {
                print('Error processing file: $e');
              }
            }
          }
        }

        print('=== END pickAudioFiles - Found ${songs.length} songs ===');
        return songs;
      }

      print('=== END pickAudioFiles - No files selected ===');
      return [];
    } catch (e) {
      print('=== ERROR in pickAudioFiles: $e ===');
      return [];
    }
  }

  Future<File> _copyToPermanentDirectory(File cachedFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final musicDir = Directory('${appDir.path}/music');

      if (!await musicDir.exists()) {
        await musicDir.create(recursive: true);
      }

      final originalName = p.basename(cachedFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = '${timestamp}_$originalName';
      final newPath = '${musicDir.path}/$newFileName';

      final newFile = await cachedFile.copy(newPath);
      print('Copied file from ${cachedFile.path} to ${newFile.path}');

      return newFile;
    } catch (e) {
      print('Error copying file: $e');
      rethrow;
    }
  }

  Future<List<SongModel>> scanAccessibleDirectories() async {
    try {
      List<SongModel> allSongs = [];

      try {
        print('Scanning Download directory...');
        final downloadSongs = await scanDownloadDirectory();
        print('Found ${downloadSongs.length} songs in Download');
        allSongs.addAll(downloadSongs);
      } catch (e) {
        print('Error scanning Download: $e');
      }

      try {
        final docDir = await getApplicationDocumentsDirectory();
        print('Scanning App Documents: ${docDir.path}');
        final docSongs = await _scanDirectory(docDir);
        print('Found ${docSongs.length} songs in App Documents');
        allSongs.addAll(docSongs);
      } catch (e) {
        print('Error scanning App Documents: $e');
      }

      try {
        final cacheDir = await getTemporaryDirectory();
        print('Scanning Cache: ${cacheDir.path}');
        final cacheSongs = await _scanDirectory(cacheDir);
        print('Found ${cacheSongs.length} songs in Cache');
        allSongs.addAll(cacheSongs);
      } catch (e) {
        print('Error scanning Cache: $e');
      }

      final uniqueSongs = <String, SongModel>{};
      for (var song in allSongs) {
        uniqueSongs[song.filePath] = song;
        print('Unique song: ${song.title} - ${song.filePath}');
      }

      return uniqueSongs.values.toList();
    } catch (e) {
      print('=== ERROR in scanAccessibleDirectories: $e ===');
      throw Exception('Lỗi khi quét thư mục: $e');
    }
  }

  Future<List<SongModel>> _scanDirectory(Directory dir) async {
    final List<SongModel> songs = [];

    print('Scanning directory: ${dir.path}');

    try {
      if (!await dir.exists()) {
        print('Directory does not exist');
        return songs;
      }

      final List<FileSystemEntity> entities = await dir
          .list(recursive: true)
          .toList();
      print('Found ${entities.length} entities in directory');

      for (final entity in entities) {
        if (entity is File) {
          final path = entity.path;
          final extension = p.extension(path).toLowerCase();

          print('Checking file: $path');
          print('Extension: $extension');

          if (_isAudioFile(entity)) {
            try {
              print('Creating SongModel for audio file: $path');
              final song = await _createSongModel(entity);
              songs.add(song);
              print('Added song: ${song.title}');
            } catch (e) {
              print('Error creating SongModel for $path: $e');
            }
          } else {
            print('Not an audio file: $extension');
          }
        }
      }
    } catch (e) {
      print('Error scanning directory ${dir.path}: $e');
    }

    print('Finished scanning directory: ${songs.length} songs found');
    return songs;
  }

  bool _isAudioFile(File file) {
    final String extension = p.extension(file.path).toLowerCase();
    return supportedFormats.contains(extension);
  }

  Future<SongModel> _createSongModel(File file) async {
    try {
      print('=== _createSongModel for: ${file.path} ===');

      final exists = await file.exists();
      if (!exists) {
        print('FILE DOES NOT EXIST: ${file.path}');
        throw Exception('File does not exist: ${file.path}');
      }

      final stat = await file.stat();
      final String fileName = p.basenameWithoutExtension(file.path);

      print('File name: $fileName');

      String title = _extractTitleFromFileName(fileName);
      String artist = _extractArtistFromFileName(fileName);
      String? album;

      if (title.isEmpty) {
        title = fileName.length > 30
            ? '${fileName.substring(0, 30)}...'
            : fileName;
      }

      if (artist.isEmpty) {
        artist = 'Unknown Artist';
      }

      final song = SongModel(
        id: file.path.hashCode.toString(),
        title: title,
        artist: artist,
        album: album,
        filePath: file.path,
        filesize: stat.size,
        duration: null,
        albumArt: null,
      );

      print('Created SongModel: ${song.title} - ${song.artist}');
      return song;
    } catch (e) {
      print('Error in _createSongModel: $e');
      return SongModel(
        id: file.path.hashCode.toString(),
        title: 'Unknown Song',
        artist: 'Unknown Artist',
        filePath: file.path,
        filesize: 0,
        duration: null,
        albumArt: null,
      );
    }
  }

  String _extractTitleFromFileName(String fileName) {
    String cleaned = fileName;

    final youtubePrefixes = ['YTSave.com_YouTube_', 'YouTube_', 'yt_', 'YT_'];

    for (var prefix in youtubePrefixes) {
      if (cleaned.contains(prefix)) {
        cleaned = cleaned.replaceAll(prefix, '');
      }
    }

    cleaned = cleaned.replaceAll(RegExp(r'_\d+$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'_\d+kbps$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'_\d+Hz$'), '');

    if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      if (parts.length >= 2) {
        String potentialTitle = parts[1].trim();

        potentialTitle = potentialTitle.replaceAll('_', ' ');
        potentialTitle = potentialTitle.replaceAll(RegExp(r'\s+'), ' ');

        if (potentialTitle.length >= 2 &&
            !potentialTitle.contains('Media') &&
            !potentialTitle.contains('wXCJEp4blGA') &&
            !potentialTitle.contains(RegExp(r'^[0-9_]+$'))) {
          return potentialTitle;
        }
      }
    }

    if (cleaned.contains('_')) {
      final parts = cleaned.split('_');
      if (parts.length >= 2) {
        for (var part in parts) {
          if (part.length >= 3 &&
              !part.contains('Media') &&
              !part.contains('wXCJEp4blGA') &&
              !RegExp(r'^[0-9]+$').hasMatch(part)) {
            return part.replaceAll('_', ' ').trim();
          }
        }
      }
    }

    return cleaned.replaceAll('_', ' ').trim();
  }

  String _extractArtistFromFileName(String fileName) {
    if (fileName.contains('-')) {
      final parts = fileName.split('-');
      if (parts.isNotEmpty) {
        String potentialArtist = parts[0].trim();

        potentialArtist = potentialArtist.replaceAll('YTSave.com_YouTube_', '');
        potentialArtist = potentialArtist.replaceAll('YouTube_', '');
        potentialArtist = potentialArtist.replaceAll('_', ' ');

        if (potentialArtist.isNotEmpty &&
            !potentialArtist.contains('Media') &&
            !potentialArtist.contains('wXCJEp4blGA')) {
          return potentialArtist;
        }
      }
    }

    return 'Unknown Artist';
  }

  Future<List<SongModel>> searchSongs(
    List<SongModel> allSongs,
    String query,
  ) async {
    if (query.isEmpty) return allSongs;

    final lowerQuery = query.toLowerCase();
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<SongModel>> getSongsByArtist(
    List<SongModel> allSongs,
    String artist,
  ) async {
    return allSongs.where((song) => song.artist == artist).toList();
  }

  Future<List<SongModel>> getSongsByAlbum(
    List<SongModel> allSongs,
    String album,
  ) async {
    return allSongs.where((song) => song.album == album).toList();
  }
}
