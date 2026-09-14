import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadItemImage(
    Uint8List imageBytes,
    String userId, {
    String contentType = 'image/jpeg',
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final reference = _storage
        .ref()
        .child('item_images')
        .child(userId)
        .child(fileName);

    await reference.putData(
      imageBytes,
      SettableMetadata(contentType: contentType),
    );

    return await reference.getDownloadURL();
  }
}
