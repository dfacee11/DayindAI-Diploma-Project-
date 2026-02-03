import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ResumeUploadService {
  Future<File?> pickResumeFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );

    if (result == null) return null;

    return File(result.files.single.path!);
  }
}