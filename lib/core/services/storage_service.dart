import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(
      String fileName,
      dynamic file,
      ) async {
    final ref = _storage.ref().child("profile_images/$fileName");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}