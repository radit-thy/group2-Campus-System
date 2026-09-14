import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/item_service.dart';
import '../../theme/app_theme.dart';
import '../report/report_item_screen.dart';
import 'item_details_screen.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  String _selectedType = 'lost';

  void _openReportOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.search_outlined,
                color: AppTheme.orange,
              ),
              title: const Text('Report Lost Item'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportItemScreen(
                      initialType: 'lost',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.inventory_2_outlined,
                color: AppTheme.orange,
              ),
              title: const Text('Report Found Item'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportItemScreen(
                      initialType: 'found',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (user == null) {
      return Center(
        child: Text(
          'Please login.',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
        ),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'My Reports',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.navy,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
                child: Text(
                  "Track and manage items you've found or reported as lost.",
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ReportTypeTabs(
                  selectedType: _selectedType,
                  onChanged: (type) {
                    setState(() => _selectedType = type);
                  },
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: ItemService().getMyItems(user.uid),

                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Unable to load your reports. Please try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final reports = (snapshot.data?.docs ?? [])
                        .where(
                          (doc) =>
                              doc.data()['type'] == _selectedType,
                        )
                        .toList();

                    if (reports.isEmpty) {
                      return Center(
                        child: Text(
                          _selectedType == 'lost'
                              ? 'You have not reported any lost items.'
                              : 'You have not reported any found items.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        0,
                        20,
                        96,
                      ),
                      itemCount: reports.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _ReportCard(doc: reports[index]),
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              onPressed: _openReportOptions,
              backgroundColor: AppTheme.orange,
              foregroundColor: AppTheme.navy,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),

      // decoration: BoxDecoration(
      //   color: theme.colorScheme.surface,
      //   border: Border(
      //     bottom: BorderSide(
      //       color: isDark
      //           ? Colors.white.withOpacity(0.08)
      //           : AppTheme.border,
      //     ),
      //   ),
      // ),

      child: Row(
        children: [
          Icon(
            Icons.school_outlined,
            color: isDark ? Colors.white : AppTheme.navy,
            size: 23,
          ),

          const SizedBox(width: 8),

          Text(
            'Campus Found',
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.navy,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          CircleAvatar(
            radius: 17,
            backgroundColor: isDark
                ? AppTheme.orange.withOpacity(0.15)
                : AppTheme.lightBlue,
            child: Icon(
              Icons.person,
              color: isDark ? AppTheme.orange : AppTheme.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeTabs extends StatelessWidget {
  const _ReportTypeTabs({
    required this.selectedType,
    required this.onChanged,
  });

  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ReportTab(
            label: 'LOST ITEMS',
            selected: selectedType == 'lost',
            onTap: () => onChanged('lost'),
          ),
        ),

        Expanded(
          child: _ReportTab(
            label: 'FOUND ITEMS',
            selected: selectedType == 'found',
            onTap: () => onChanged('found'),
          ),
        ),
      ],
    );
  }
}

class _ReportTab extends StatelessWidget {
  const _ReportTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,

      child: Container(
        height: 42,
        alignment: Alignment.center,

        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? (isDark ? AppTheme.orange : AppTheme.navy)
                  : (isDark
                      ? Colors.white.withOpacity(0.12)
                      : AppTheme.border),
              width: selected ? 3 : 1,
            ),
          ),
        ),

        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? (isDark ? AppTheme.orange : AppTheme.navy)
                : theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.doc});

  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final data = doc.data();

    final imageUrl = data['imageUrl']?.toString() ?? '';

    final status = data['status']?.toString() ?? 'available';

    final createdAt = data['createdAt'] as Timestamp?;

    final dateText = createdAt == null
        ? 'Recently reported'
        : 'Reported: ${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}';

    final isMatched = status == 'claimed';

    return InkWell(
      borderRadius: BorderRadius.circular(12),

      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailsScreen(
            itemId: doc.id,
          ),
        ),
      ),

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppTheme.border,
          ),

          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withOpacity(
                isDark ? 0.25 : 0.06,
              ),
            ),
          ],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),

              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,

                      errorBuilder: (_, _, _) =>
                          const _ItemPlaceholder(),
                    )
                  : const _ItemPlaceholder(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['title']?.toString() ??
                              'Unknown item',

                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppTheme.navy,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      _StatusChip(
                        isMatched: isMatched,
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    data['location']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateText,
                          style: TextStyle(
                            color:
                                theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      Text(
                        'DETAILS >',
                        style: TextStyle(
                          color: isDark
                              ? AppTheme.orange
                              : AppTheme.navy,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemPlaceholder extends StatelessWidget {
  const _ItemPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 72,
      height: 72,

      color: isDark
          ? AppTheme.navy.withOpacity(0.5)
          : AppTheme.paleBlue,

      child: Icon(
        Icons.inventory_2_outlined,
        color: isDark
            ? AppTheme.orange
            : AppTheme.navy,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.isMatched,
  });

  final bool isMatched;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: isMatched
            ? (isDark
                ? AppTheme.matchedBg.withOpacity(0.25)
                : AppTheme.matchedBg)
            : (isDark
                ? AppTheme.pendingBg.withOpacity(0.25)
                : AppTheme.pendingBg),
        borderRadius: BorderRadius.circular(99),
      ),

      child: Text(
        isMatched ? 'MATCHED' : 'PENDING',

        style: TextStyle(
          color: isMatched
              ? AppTheme.matchedText
              : AppTheme.pendingText,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}