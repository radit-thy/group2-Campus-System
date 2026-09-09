import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/item_service.dart';
import '../../theme/app_theme.dart';
import 'item_details_screen.dart';

class FoundScreen extends StatelessWidget {
  const FoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Found Items'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: ItemService().getFoundItems(),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No found items reported yet.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),

                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemDetailsScreen(itemId: doc.id),
                    ),
                  ),
                  child: ListTile(
                    leading: data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              data['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const CircleAvatar(
                            backgroundColor: AppTheme.lightBlue,
                            child: Icon(Icons.inventory_2),
                          ),

                    title: Text(data['title'] ?? 'Unknown'),

                    subtitle: Text(data['location'] ?? ''),
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
