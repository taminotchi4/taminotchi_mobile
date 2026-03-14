import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';

class GalleryService {
  final ImagePicker _picker = ImagePicker();

  Future<bool> hasPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  Future<List<File>> getRecentImages({int count = 50}) async {
    try {
      if (!await hasPermission()) {
        return [];
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) {
        return [];
      }

      final List<AssetEntity> media = await albums[0].getAssetListRange(
        start: 0,
        end: count,
      );

      final List<File> files = [];
      for (final asset in media) {
        final file = await asset.file;
        if (file != null) {
          files.add(file);
        }
      }

      return files;
    } catch (e) {
      print('Error getting images: $e');
      return [];
    }
  }

  Future<File?> pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Error picking from camera: $e');
      return null;
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
}
