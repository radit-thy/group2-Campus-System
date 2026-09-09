import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadItemImage(
    File image,
    String userId,
  ) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final reference = _storage
        .ref()
        .child('item_images')
        .child(userId)
        .child(fileName);

    await reference.putFile(
      image,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    return await reference.getDownloadURL();
  }
}