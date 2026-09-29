import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../constants/cloudinary_config.dart';

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;
  final String originalFilename;
  final int bytes;
  final String format;
  final int width;
  final int height;

  CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    required this.originalFilename,
    required this.bytes,
    required this.format,
    required this.width,
    required this.height,
  });

  factory CloudinaryUploadResult.fromMap(Map<String, dynamic> map) {
    return CloudinaryUploadResult(
      secureUrl: map['secure_url'] ?? '',
      publicId: map['public_id'] ?? '',
      originalFilename: map['original_filename'] ?? '',
      bytes: map['bytes'] ?? 0,
      format: map['format'] ?? '',
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'secure_url': secureUrl,
      'public_id': publicId,
      'original_filename': originalFilename,
      'bytes': bytes,
      'format': format,
      'width': width,
      'height': height,
    };
  }
}

class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  bool isAllowedImageExtension(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return CloudinaryConfig.allowedImageExtensions.contains(ext);
  }

  bool isAllowedImageByBytes(List<int> bytes) {
    if (bytes.length < 4) return false;
    final b0 = bytes[0],
        b1 = bytes[1],
        b2 = bytes[2],
        b3 = bytes.length > 3 ? bytes[3] : 0;
    final isJpg = b0 == 0xFF && b1 == 0xD8 && b2 == 0xFF;
    final isPng = b0 == 0x89 && b1 == 0x50 && b2 == 0x4E && b3 == 0x47;
    return isJpg || isPng;
  }

  ({bool valid, String error}) validateFile(String filePath, List<int> bytes) {
    if (!isAllowedImageExtension(filePath)) {
      return (
        valid: false,
        error: 'Invalid file type. Only JPG, JPEG, and PNG are allowed.',
      );
    }
    if (bytes.isEmpty) {
      return (valid: false, error: 'File is empty.');
    }
    if (!isAllowedImageByBytes(bytes)) {
      return (
        valid: false,
        error:
            'File content does not match allowed types. Only JPG, JPEG, PNG allowed.',
      );
    }
    if (bytes.length > CloudinaryConfig.maxFileSizeBytes) {
      return (valid: false, error: 'File is too large. Maximum size is 10MB.');
    }
    return (valid: true, error: '');
  }

  Future<CloudinaryUploadResult> uploadImage({
    required File file,
    String folder = 'medduty',
    String? uploadPreset,
  }) async {
    final bytes = await file.readAsBytes();
    final validation = validateFile(file.path, bytes);
    if (!validation.valid) {
      throw Exception(validation.error);
    }

    final preset = uploadPreset ?? CloudinaryConfig.uploadPreset;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(CloudinaryConfig.unsignedUploadUrl),
    );
    request.fields['upload_preset'] = preset;
    request.fields['folder'] = folder;
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: p.basename(file.path),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return CloudinaryUploadResult.fromMap(data);
  }
}
