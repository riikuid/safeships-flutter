import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class AppHelper {
  static Icon getFileIcon(String filePath) {
    // Extract the file extension (converted to lowercase for consistency)
    String extension = path.extension(filePath).toLowerCase();

    // Define supported extensions
    const imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];
    const videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv'];
    const documentExtensions = [
      '.pdf',
      '.doc',
      '.docx',
      '.txt',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx'
    ];

    // Check the extension and return the appropriate icon
    if (imageExtensions.contains(extension)) {
      return const Icon(Icons.image);
    } else if (videoExtensions.contains(extension)) {
      return const Icon(Icons.ondemand_video);
    } else {
      // Default to document icon for unsupported or document extensions
      return const Icon(Icons.description);
    }
  }
}
