import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/item_service.dart';
import '../../theme/app_theme.dart';
import 'item_details_screen.dart';

class FoundScreen extends StatelessWidget {
  const FoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      toolbarHeight: 65,
      title: Row(
        children: [
          Icon(
            Icons.school_outlined,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.navy,
            size: 23,
          ),

          const SizedBox(width: 8),

          Text(
            'Campus Found',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.navy,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          CircleAvatar(
            radius: 17,
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.orange.withOpacity(0.15)
                    : AppTheme.lightBlue,
            child: Icon(
              Icons.person,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.orange
                  : AppTheme.navy,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found Items',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
  ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
              final data = doc.data();

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