import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ResumeUploadService {
  // PDF/TXT
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
      print("File picker error: $e");
      return null;
    }
  }

  // Choose photo from gallery
  Future<File?> pickResumeImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print("Gallery picker error: $e");
      return null;
    }
  }

  // Take photo using camera
  Future<File?> takeResumePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print("Camera picker error: $e");
      return null;
    }
  }
}