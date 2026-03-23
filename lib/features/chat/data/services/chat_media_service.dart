import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Telegram-style chat media cache service.
/// Downloads image/audio from server, stores locally.
/// LRU eviction when cache exceeds [_maxCacheBytes].
class ChatMediaService {
  static const int _maxCacheBytes = 150 * 1024 * 1024; // 150 MB
  static const int _maxMessagesPerChat = 100;

  final Dio _dio;
  ChatMediaService({Dio? dio}) : _dio = dio ?? Dio();

  // ─── Public API ───────────────────────────────────────────────

  /// Returns a local file path for [serverUrl].
  /// - If file is already cached → returns it immediately.
  /// - Otherwise downloads it, caches it, then returns the path.
  Future<String?> getLocalPath(String serverUrl, String type) async {
    try {
      final localPath = await _buildLocalPath(serverUrl, type);
      final file = File(localPath);
      if (await file.exists()) return localPath;

      await _ensureDir(type);
      await _enforceLimit();
      await _download(serverUrl, localPath);
      return localPath;
    } catch (e) {
      return null;
    }
  }

  /// Checks if a media file is already cached without downloading.
  Future<bool> isCached(String serverUrl, String type) async {
    final localPath = await _buildLocalPath(serverUrl, type);
    return File(localPath).exists();
  }

  /// Deletes all cached media for a chat.
  Future<void> clearAll() async {
    final baseDir = await _baseDir();
    final dir = Directory(baseDir);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  // ─── Internal ─────────────────────────────────────────────────

  Future<String> _baseDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/chat';
  }

  Future<String> _buildLocalPath(String serverUrl, String type) async {
    final base = await _baseDir();
    final folder = type == 'audio' ? 'audio' : 'images';
    final filename = _hashUrl(serverUrl);
    final ext = _guessExtension(serverUrl, type);
    return '$base/$folder/$filename$ext';
  }

  Future<void> _ensureDir(String type) async {
    final base = await _baseDir();
    final folder = type == 'audio' ? 'audio' : 'images';
    await Directory('$base/$folder').create(recursive: true);
  }

  Future<void> _download(String url, String localPath) async {
    await _dio.download(url, localPath);
  }

  // Simple hash from URL for a stable filename
  String _hashUrl(String url) {
    var hash = 0;
    for (var ch in url.codeUnits) {
      hash = (hash * 31 + ch) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  String _guessExtension(String url, String type) {
    if (url.contains('.jpg') || url.contains('.jpeg')) return '.jpg';
    if (url.contains('.png')) return '.png';
    if (url.contains('.mp4')) return '.mp4';
    if (url.contains('.mp3')) return '.mp3';
    if (url.contains('.m4a')) return '.m4a';
    if (url.contains('.aac')) return '.aac';
    if (url.contains('.ogg')) return '.ogg';
    return type == 'audio' ? '.m4a' : '.jpg';
  }

  /// LRU eviction: delete oldest files until total size < [_maxCacheBytes].
  Future<void> _enforceLimit() async {
    try {
      final base = await _baseDir();
      final dir = Directory(base);
      if (!await dir.exists()) return;

      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .toList();

      int totalBytes = files.fold(0, (sum, f) => sum + f.lengthSync());

      if (totalBytes <= _maxCacheBytes) return;

      // Sort by last modified → oldest first
      files.sort((a, b) =>
          a.statSync().modified.compareTo(b.statSync().modified));

      for (final file in files) {
        if (totalBytes <= _maxCacheBytes) break;
        final size = file.lengthSync();
        file.deleteSync();
        totalBytes -= size;
      }
    } catch (_) {}
  }

  // ─── MessageModel helper ──────────────────────────────────────

  /// Returns bounds for how many messages per chat we keep locally.
  int get maxMessagesPerChat => _maxMessagesPerChat;
}
