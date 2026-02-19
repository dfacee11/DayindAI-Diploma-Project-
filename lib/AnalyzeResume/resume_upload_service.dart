import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ResumeUploadService {
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
      debugPrint("File picker error: $e");
      return null;
    }
  }

  Future<File?> pickResumeImageFromGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint("Gallery picker error: $e");
      return null;
    }
  }

  Future<File?> takeResumePhoto() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint("Camera picker error: $e");
      return null;
    }
  }
}