import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ResumeUploadService {
<<<<<<< HEAD
  final ImagePicker _imagePicker = ImagePicker();

  // 📄 PDF / TXT
=======
  // PDF/TXT
>>>>>>> 7ba1829 (updated analyze page)
  Future<File?> pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );

<<<<<<< HEAD
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
=======
    if (result == null) return null;
    return File(result.files.single.path!);
>>>>>>> 7ba1829 (updated analyze page)
  }

  // Choose photo from gallery
  Future<File?> pickResumeImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }

  // Take photo using camera
  Future<File?> takeResumePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image == null) return null;
    return File(image.path);
  }
}