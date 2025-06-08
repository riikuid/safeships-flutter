import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:safeships_flutter/theme.dart';

class AppHelper {
  static IconData getFileIcon(String filePath) {
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
      return Icons.image;
    } else if (videoExtensions.contains(extension)) {
      return Icons.ondemand_video;
    } else {
      // Default to document icon for unsupported or document extensions
      return Icons.description;
    }
  }

  static String formatDateToString(DateTime date) {
    final format = DateFormat('dd MMMM yyyy');
    return format.format(date);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 3) {
      return formatDateToString(date);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static Color getColorBasedOnStatus(String status) {
    status = status.toLowerCase(); // Case-insensitive comparison

    switch (status) {
      case 'approved' || 'completed':
        return greenLableColor;
      case 'rejected' || 'failed':
        return redLableColor;
      case 'deleted':
        return redLableColor;
      default:
        return orangeLableColor;
    }
  }
}
