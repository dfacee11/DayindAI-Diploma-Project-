import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ResumeUploadService {
  final ImagePicker _imagePicker = ImagePicker();

  // 📄 PDF / TXT
  Future<File?> pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

      if (result == null) return null;

      final path = result.files.single.path;
      if (path == null) return null;

      return File(path);
    } catch (e) {
      print('File picker error: $e');
      return null;
    }
  }

  // 🖼 Gallery image
  Future<File?> pickResumeImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      print('Image picker error: $e');
      return null;
    }
  }
}