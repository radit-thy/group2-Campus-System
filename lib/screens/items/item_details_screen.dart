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

  const ItemDetailsScreen({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('items')
              .doc(itemId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.orange,
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text(
                  'This item is no longer available.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            }

            final data = snapshot.data!.data()!;

            return _ItemDetailsBody(
              itemId: itemId,
              data: data,
            );
          },
        ),
      ),
    );
  }
}

class _ItemDetailsBody extends StatelessWidget {
  final String itemId;
  final Map<String, dynamic> data;

  const _ItemDetailsBody({
    required this.itemId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String title = data['title'] ?? 'Unknown item';
    final String type = data['type'] ?? 'found';
    final String status = data['status'] ?? 'available';
    final String description = data['description'] ?? '';
    final String location = data['location'] ?? '';
    final String imageUrl = data['imageUrl'] ?? '';
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    final primaryTextColor = isDark ? Colors.white : AppTheme.navy;
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : AppTheme.textGrey;

    return Column(
      children: [
        // ------------------------------------------------------------
        // Top bar
        // ------------------------------------------------------------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.arrow_back,
                    color: primaryTextColor,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.school_outlined,
                color: primaryTextColor,
                size: 20,
              ),

              const SizedBox(width: 6),

              Text(
                'Campus Found',
                style: TextStyle(
                  color: primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              CircleAvatar(
                radius: 16,
                backgroundColor: isDark
                    ? AppTheme.orange.withOpacity(0.15)
                    : AppTheme.lightBlue,
                child: Icon(
                  Icons.person,
                  color: isDark
                      ? AppTheme.orange
                      : AppTheme.navy,
                  size: 18,
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------------------
        // Main content
        // ------------------------------------------------------------
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------
                // Photo + type badge
                // ----------------------------------------------------
                Stack(
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 230,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 230,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : AppTheme.iconBlue,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: isDark
                                      ? AppTheme.orange
                                      : AppTheme.navy,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: double.infinity,
                            height: 230,
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : AppTheme.iconBlue,
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: isDark
                                  ? AppTheme.orange
                                  : AppTheme.navy,
                            ),
                          ),

                    // Type badge
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: type == 'found'
                              ? AppTheme.orange
                              : AppTheme.navy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
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

                // ----------------------------------------------------
                // Details
                // ----------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          _StatusBadge(
                            status: status,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Date
                      if (createdAt != null)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(createdAt.toDate()),
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // Description
                      // ------------------------------------------------
                      Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: secondaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        description.isEmpty
                            ? 'No description provided.'
                            : description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? const Color(0xFFE2E8F0)
                              : AppTheme.textDark,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ------------------------------------------------
                      // Location
                      // ------------------------------------------------
                      Text(
                        'LOCATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: secondaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.transparent,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : AppTheme.border,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: isDark
                                  ? AppTheme.orange
                                  : AppTheme.navy,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                location.isEmpty
                                    ? 'Not specified'
                                    : location,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: primaryTextColor,
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

        // --------------------------------------------------------------
        // Bottom action bar
        // --------------------------------------------------------------
        Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            16,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : AppTheme.border,
              ),
            ),
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
                          const SnackBar(
                            content: Text('Marked as claimed'),
                          ),
                        );
                      }
                    },
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
              ),
              label: Text(
                status == 'claimed'
                    ? 'Already Claimed'
                    : 'Claim Item',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                disabledBackgroundColor: isDark
                    ? const Color(0xFF334155)
                    : Colors.grey.shade300,
                foregroundColor: Colors.white,
                disabledForegroundColor: isDark
                    ? const Color(0xFF94A3B8)
                    : Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case 'claimed':
        bg = isDark
            ? AppTheme.claimedBg.withOpacity(0.25)
            : AppTheme.claimedBg;
        fg = AppTheme.claimedText;
        label = 'CLAIMED';
        break;

      case 'matched':
        bg = isDark
            ? AppTheme.matchedBg.withOpacity(0.25)
            : AppTheme.matchedBg;
        fg = AppTheme.matchedText;
        label = 'MATCHED';
        break;

      default:
        bg = isDark
            ? AppTheme.pendingBg.withOpacity(0.25)
            : AppTheme.pendingBg;
        fg = AppTheme.pendingText;
        label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}