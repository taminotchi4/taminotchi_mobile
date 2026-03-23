import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class ImageCacheService {
  final Dio _dio = Dio();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Gets the local path for a cached image. Returns null if not cached or expired.
  Future<String?> getLocalPath(String url) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cached_images',
      where: 'url = ?',
      whereArgs: [url],
    );

    if (maps.isEmpty) return null;

    final expiresAt = DateTime.parse(maps.first['expiresAt']);
    if (DateTime.now().isAfter(expiresAt)) {
      // Expired - delete file and entry
      await deleteEntry(url);
      return null;
    }

    final path = maps.first['localPath'];
    if (await File(path).exists()) {
      return path;
    } else {
      // File missing - cleanup db
      await deleteEntry(url);
      return null;
    }
  }

  /// Downloads an image and saves it for 3 days.
  Future<String?> downloadAndCache(String url) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(Uri.parse(url).path)}';
      final localPath = join(appDir.path, 'cache_images', fileName);

      // Create directory if not exists
      final dir = Directory(dirname(localPath));
      if (!await dir.exists()) await dir.create(recursive: true);

      // Download
      await _dio.download(url, localPath);

      // Save to DB
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 3));

      final db = await _dbHelper.database;
      await db.insert(
        'cached_images',
        {
          'url': url,
          'localPath': localPath,
          'downloadedAt': now.toIso8601String(),
          'expiresAt': expiresAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return localPath;
    } catch (e) {
      print('❌ Error downloading image: $e');
      return null;
    }
  }

  Future<void> deleteEntry(String url) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cached_images',
      where: 'url = ?',
      whereArgs: [url],
    );

    if (maps.isNotEmpty) {
      final path = maps.first['localPath'];
      final file = File(path);
      if (await file.exists()) await file.delete();
      await db.delete('cached_images', where: 'url = ?', whereArgs: [url]);
    }
  }

  /// Cleanup all expired images.
  Future<void> cleanupExpired() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();
    
    final List<Map<String, dynamic>> expired = await db.query(
      'cached_images',
      where: 'expiresAt < ?',
      whereArgs: [now],
    );

    for (var item in expired) {
      final path = item['localPath'];
      final file = File(path);
      if (await file.exists()) await file.delete();
    }

    await db.delete(
      'cached_images',
      where: 'expiresAt < ?',
      whereArgs: [now],
    );
  }
}
