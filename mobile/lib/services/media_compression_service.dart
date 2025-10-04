import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for compressing multimedia files (images, videos, audio)
class MediaCompressionService {
  MediaCompressionService._();
  static final MediaCompressionService instance = MediaCompressionService._();

  /// Compress an image file
  /// Returns the compressed file path and metadata
  Future<CompressedMedia> compressImage(
    File imageFile, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        throw Exception('Image compression failed');
      }

      final compressedFile = File(result.path);
      final originalSize = await imageFile.length();
      final compressedSize = await compressedFile.length();

      // Get image dimensions
      final decodedImage = await decodeImageFromList(
        await compressedFile.readAsBytes(),
      );

      return CompressedMedia(
        file: compressedFile,
        originalSize: originalSize,
        compressedSize: compressedSize,
        width: decodedImage.width,
        height: decodedImage.height,
        compressionRatio: (1 - (compressedSize / originalSize)) * 100,
      );
    } catch (e) {
      debugPrint('Error compressing image: $e');
      rethrow;
    }
  }

  /// Compress a video file
  /// Returns the compressed file path and metadata
  Future<CompressedMedia> compressVideo(
    File videoFile, {
    VideoQuality quality = VideoQuality.MediumQuality,
  }) async {
    try {
      final info = await VideoCompress.compressVideo(
        videoFile.path,
        quality: quality,
        deleteOrigin: false,
        includeAudio: true,
      );

      if (info == null || info.file == null) {
        throw Exception('Video compression failed');
      }

      final originalSize = await videoFile.length();
      final compressedSize = info.filesize ?? 0;

      return CompressedMedia(
        file: info.file!,
        originalSize: originalSize,
        compressedSize: compressedSize,
        width: info.width?.toInt(),
        height: info.height?.toInt(),
        duration: info.duration?.toInt(),
        compressionRatio: (1 - (compressedSize / originalSize)) * 100,
      );
    } catch (e) {
      debugPrint('Error compressing video: $e');
      rethrow;
    }
  }

  /// Compress an audio file using AAC codec
  /// Returns the compressed file path and metadata
  Future<CompressedMedia> compressAudio(
    File audioFile, {
    int bitrate = 128, // kbps
  }) async {
    try {
      // For audio compression, we would typically use FFmpeg or a similar library
      // For now, we'll just copy the file and return its info
      // In a production app, integrate FFmpeg for proper audio compression

      final originalSize = await audioFile.length();

      // TODO: Implement actual audio compression using FFmpeg
      // For now, just return the original file
      debugPrint('Audio compression not yet implemented. Returning original file.');

      return CompressedMedia(
        file: audioFile,
        originalSize: originalSize,
        compressedSize: originalSize,
        compressionRatio: 0,
      );
    } catch (e) {
      debugPrint('Error compressing audio: $e');
      rethrow;
    }
  }

  /// Generate a thumbnail for a video
  Future<File?> generateVideoThumbnail(File videoFile) async {
    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        videoFile.path,
        quality: 75,
      );

      return thumbnail;
    } catch (e) {
      debugPrint('Error generating video thumbnail: $e');
      return null;
    }
  }

  /// Clean up temporary compressed files
  Future<void> cleanupTempFiles() async {
    try {
      await VideoCompress.deleteAllCache();
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}

/// Result of media compression
class CompressedMedia {
  const CompressedMedia({
    required this.file,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    this.width,
    this.height,
    this.duration,
  });

  final File file;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio; // Percentage
  final int? width;
  final int? height;
  final int? duration; // Duration in seconds for video/audio

  String get formattedOriginalSize => _formatBytes(originalSize);
  String get formattedCompressedSize => _formatBytes(compressedSize);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
