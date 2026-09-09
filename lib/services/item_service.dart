import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _items =>
      _firestore.collection('items');

  Future<void> createItem({
    required String title,
    required String description,
    required String category,
    required String type,
    required String location,
    required String imageUrl,
    required String userId,
  }) async {
    await _items.add({
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'location': location,
      'imageUrl': imageUrl,
      'userId': userId,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFoundItems() {
    return _items
        .where('type', isEqualTo: 'found')
        .where('status', isEqualTo: 'available')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLostItems() {
    return _items
        .where('type', isEqualTo: 'lost')
        .where('status', isEqualTo: 'available')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyItems(
    String userId,
  ) {
    return _items
        .where('userId', isEqualTo: userId)
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  Future<void> claimItem(String itemId) async {
    final item = _items.doc(itemId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(item);
      final data = snapshot.data();
      if (!snapshot.exists || data?['status'] != 'available') {
        throw StateError('This item has already been claimed or removed.');
      }

      transaction.update(item, {
        'status': 'claimed',
        'claimedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
