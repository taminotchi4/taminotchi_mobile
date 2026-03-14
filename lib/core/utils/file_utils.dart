import 'dart:io';

class FileUtils {
  /// Get file size in human-readable format
  static String getFileSize(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return '0 B';
      
      final bytes = file.lengthSync();
      return formatBytes(bytes);
    } catch (e) {
      return '0 B';
    }
  }

  /// Format bytes to human-readable format
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    final size = bytes / (1 << (i * 10));
    
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Get audio duration from file (placeholder - returns fake duration based on file size)
  static String getAudioDuration(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return '0:00';
      
      // Fake duration based on file size (1 MB ≈ 1 minute)
      final bytes = file.lengthSync();
      final seconds = (bytes / (1024 * 1024) * 60).round();
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    } catch (e) {
      return '0:00';
    }
  }
}
