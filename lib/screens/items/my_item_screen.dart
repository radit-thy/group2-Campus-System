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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search_outlined),
              title: const Text('Report Lost Item'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportItemScreen(initialType: 'lost'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Report Found Item'),
              onTap: () {
                Navigator.pop(sheetContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ReportItemScreen(initialType: 'found'),
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

    if (user == null) {
      return const Center(child: Text('Please login.'));
    }

    return SafeArea(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'My Reports',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 22),
                child: Text(
                  "Track and manage items you've found or reported as lost.",
                  style: TextStyle(color: AppTheme.textGrey, height: 1.35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ReportTypeTabs(
                  selectedType: _selectedType,
                  onChanged: (type) => setState(() => _selectedType = type),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: ItemService().getMyItems(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Unable to load your reports. Please try again.',
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reports = (snapshot.data?.docs ?? [])
                        .where((doc) => doc.data()['type'] == _selectedType)
                        .toList();

                    if (reports.isEmpty) {
                      return Center(
                        child: Text(
                          _selectedType == 'lost'
                              ? 'You have not reported any lost items.'
                              : 'You have not reported any found items.',
                          style: const TextStyle(color: AppTheme.textGrey),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                      itemCount: reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: const Row(
        children: [
          Icon(Icons.school_outlined, color: AppTheme.navy, size: 23),
          SizedBox(width: 8),
          Text(
            'Campus Found',
            style: TextStyle(
              color: AppTheme.navy,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Spacer(),
          CircleAvatar(
            radius: 17,
            backgroundColor: AppTheme.lightBlue,
            child: Icon(Icons.person, color: AppTheme.navy),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeTabs extends StatelessWidget {
  const _ReportTypeTabs({required this.selectedType, required this.onChanged});

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
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppTheme.navy : AppTheme.border,
              width: selected ? 3 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.navy : AppTheme.textGrey,
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
        MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: doc.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
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
                      errorBuilder: (_, _, _) => const _ItemPlaceholder(),
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
                          data['title']?.toString() ?? 'Unknown item',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(isMatched: isMatched),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['location']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateText,
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Text(
                        'DETAILS >',
                        style: TextStyle(
                          color: AppTheme.navy,
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
    return Container(
      width: 72,
      height: 72,
      color: AppTheme.paleBlue,
      child: const Icon(Icons.inventory_2_outlined, color: AppTheme.navy),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isMatched});

  final bool isMatched;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMatched ? AppTheme.matchedBg : AppTheme.pendingBg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isMatched ? 'MATCHED' : 'PENDING',
        style: TextStyle(
          color: isMatched ? AppTheme.matchedText : AppTheme.pendingText,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
