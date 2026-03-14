import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/post_image_entity.dart';

class HomeMediaPicker {
  final ImagePicker _imagePicker = ImagePicker();

  Future<List<PostImageEntity>> pickFromGallery() async {
    final files = await _imagePicker.pickMultiImage();
    if (files.isEmpty) return [];
    return files
        .where((file) => file.path.isNotEmpty)
        .map((file) => PostImageEntity(path: file.path, isLocal: true))
        .toList();
  }

  Future<PostImageEntity?> pickFromCamera() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);
    if (file == null) return null;
    return PostImageEntity(path: file.path, isLocal: true);
  }

  Future<List<PostImageEntity>> pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return [];
    return result.files
        .where((file) => file.path != null && file.path!.isNotEmpty)
        .map((file) => PostImageEntity(path: file.path!, isLocal: true))
        .toList();
  }
}
