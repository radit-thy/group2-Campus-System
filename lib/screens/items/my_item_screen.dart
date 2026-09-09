import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/item_service.dart';

class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Items'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            ItemService().getMyItems(
          user.uid,
        ),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have not reported any items.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),

            itemCount:
                snapshot.data!.docs.length,

            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index]
                      .data()
                      as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(
                    data['title'] ??
                        'Unknown',
                  ),

                  subtitle: Text(
                    '${data['type']} • ${data['status']}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}