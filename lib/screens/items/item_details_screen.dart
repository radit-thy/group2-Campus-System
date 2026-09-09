import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/item_service.dart';
import '../../theme/app_theme.dart';

/// Full detail view for a single lost/found item document.
///
/// Navigate here with the Firestore document id:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => ItemDetailsScreen(itemId: doc.id),
/// ));
/// ```
class ItemDetailsScreen extends StatelessWidget {
  final String itemId;
  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .doc(itemId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('This item is no longer available.'));
            }

            final data = snapshot.data!.data()!;
            return _ItemDetailsBody(itemId: itemId, data: data);
          },
        ),
      ),
    );
  }
}

class _ItemDetailsBody extends StatelessWidget {
  final String itemId;
  final Map<String, dynamic> data;
  const _ItemDetailsBody({required this.itemId, required this.data});

  @override
  Widget build(BuildContext context) {
    final String title = data['title'] ?? 'Unknown item';
    final String type = data['type'] ?? 'found'; // 'lost' | 'found'
    final String status = data['status'] ?? 'available';
    final String description = data['description'] ?? '';
    final String location = data['location'] ?? '';
    final String imageUrl = data['imageUrl'] ?? '';
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.arrow_back, color: AppTheme.navy),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.school_outlined, color: AppTheme.navy, size: 20),
              const SizedBox(width: 6),
              const Text(
                'Campus Found',
                style: TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.lightBlue,
                child: Icon(Icons.person, color: AppTheme.navy, size: 18),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo + type badge
                Stack(
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 230,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: double.infinity,
                            height: 230,
                            color: AppTheme.iconBlue,
                            child: const Icon(Icons.image, size: 48, color: AppTheme.navy),
                          ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: type == 'found' ? AppTheme.orange : AppTheme.navy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              type == 'found' ? 'Found' : 'Lost',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.navy,
                              ),
                            ),
                          ),
                          _StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (createdAt != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textGrey),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(createdAt.toDate()),
                              style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      const Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description.isEmpty ? 'No description provided.' : description,
                        style: const TextStyle(fontSize: 14, height: 1.5, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'LOCATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: AppTheme.navy),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                location.isEmpty ? 'Not specified' : location,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.navy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom action bar
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: status == 'claimed'
                  ? null
                  : () async {
                      await ItemService().claimItem(itemId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Marked as claimed')),
                        );
                      }
                    },
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: Text(status == 'claimed' ? 'Already Claimed' : 'Claim Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case 'claimed':
        bg = AppTheme.claimedBg;
        fg = AppTheme.claimedText;
        label = 'CLAIMED';
        break;
      case 'matched':
        bg = AppTheme.matchedBg;
        fg = AppTheme.matchedText;
        label = 'MATCHED';
        break;
      default:
        bg = AppTheme.pendingBg;
        fg = AppTheme.pendingText;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
