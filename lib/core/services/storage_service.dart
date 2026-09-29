import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadProfileImage(
    String fileName,
    dynamic file,
  ) async {
    try {
      final path = 'profile_images/$fileName';
      if (file is Uint8List) {
        await _supabase.storage.from(SupabaseConstants.profileImagesBucket).uploadBinary(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
      } else {
        await _supabase.storage.from(SupabaseConstants.profileImagesBucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
      }
      return _supabase.storage.from(SupabaseConstants.profileImagesBucket).getPublicUrl(path);
    } catch (_) {
      return '';
    }
  }
}
