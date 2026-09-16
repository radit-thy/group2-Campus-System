import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/item_service.dart';
import '../theme/app_theme.dart';
import 'report/report_item_screen.dart';
import 'items/lost_screen.dart';
import 'items/found_screen.dart';
import 'items/item_details_screen.dart';
import 'items/my_item_screen.dart';
import 'profile/profile_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    HomeDashboard(),
    LostScreen(),
    FoundScreen(),
    MyItemsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppTheme.orange,
              foregroundColor: AppTheme.navy,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportItemScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,

      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final searchController = TextEditingController();

  String search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,

            title: Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: isDark ? Colors.white : AppTheme.navy,
                ),

                const SizedBox(width: 8),

                Text(
                  'Campus Found',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            actions: [
              CircleAvatar(
                backgroundColor: isDark
                    ? AppTheme.orange.withOpacity(0.15)
                    : AppTheme.lightBlue,
                child: Icon(
                  Icons.person,
                  color: isDark ? AppTheme.orange : AppTheme.navy,
                ),
              ),

              const SizedBox(width: 16),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroSearch(context),

                const SizedBox(height: 16),

                _buildQuickActions(context),

                const SizedBox(height: 16),

                _buildCategories(context),

                const SizedBox(height: 16),

                _buildRecentlyFound(context),

                const SizedBox(height: 16),

                _buildStatistics(context),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSearch(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Lost something? We'll\nhelp find it.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: searchController,

            onChanged: (value) {
              setState(() {
                search = value;
              });
            },

            decoration: const InputDecoration(
              hintText: 'Search for keys, phones, or wallets...',
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _actionCard(
            title: 'REPORT LOST',
            icon: Icons.person_search,
            color: isDark
                ? AppTheme.orange.withOpacity(0.85)
                : AppTheme.orange,
            onTap: () {
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
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _actionCard(
            title: 'REPORT FOUND',
            icon: Icons.inventory_2_outlined,
            color: isDark
                ? const Color(0xFF1E5A82)
                : AppTheme.lightBlue,
            onTap: () {
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
        ),
      ],
    );
  }

  Widget _actionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : AppTheme.border,
          ),
        ),

        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.navy,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
                color: isDark ? Colors.white : AppTheme.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final categories = [
      {'name': 'Electronics', 'icon': Icons.devices_other},
      {'name': 'Keys', 'icon': Icons.key},
      {'name': 'Wallet', 'icon': Icons.account_balance_wallet},
      {'name': 'Books', 'icon': Icons.book},
      {'name': 'ID Cards', 'icon': Icons.badge},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.navy,
              ),
            ),

            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.orange
                      : AppTheme.navy,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 100,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            itemCount: categories.length,

            separatorBuilder: (_, __) => const SizedBox(width: 12),

            itemBuilder: (context, index) {
              final category = categories[index];

              return SizedBox(
                width: 82,

                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,

                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.navy.withOpacity(0.7)
                            : AppTheme.iconBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : AppTheme.border,
                        ),
                      ),

                      child: Icon(
                        category['icon'] as IconData,
                        color: isDark
                            ? AppTheme.orange
                            : AppTheme.navy,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      category['name'] as String,
                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyFound(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Recently Found',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.navy,
          ),
        ),

        const SizedBox(height: 12),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ItemService().getFoundItems(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _emptyItems(context);
            }

            final docs = snapshot.data!.docs;

            return Column(
              children: docs
                  .take(4)
                  .map(
                    (doc) => _itemCard(context, doc),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _itemCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final data = doc.data();

    final imageUrl = data['imageUrl'] ?? '';

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
        margin: const EdgeInsets.only(bottom: 16),

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
              blurRadius: 4,
              color: Colors.black.withOpacity(
                isDark ? 0.25 : 0.08,
              ),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),

                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'Unknown item',

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppTheme.navy,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: AppTheme.orange,
                          borderRadius: BorderRadius.circular(999),
                        ),

                        child: Text(
                          'NEW MATCH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          data['location'] ?? '',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () async {
                        await ItemService().claimItem(doc.id);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Item claimed successfully',
                              ),
                            ),
                          );
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.navy,
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),

                      child: const Text('Claim Item'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyItems(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(32),

      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.navy.withOpacity(0.5)
            : AppTheme.paleBlue,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: isDark
                ? AppTheme.orange
                : AppTheme.navy,
          ),

          const SizedBox(height: 8),

          Text(
            'No items found yet.',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),

      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : AppTheme.paleBlue,
        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : AppTheme.border,
        ),
      ),

      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ItemService().getDashboardItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load statistics'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs
              .map((document) => document.data())
              .toList();
          final lostCount = items.where((item) => item['type'] == 'lost').length;
          final foundItems =
              items.where((item) => item['type'] == 'found').toList();
          final foundCount = foundItems.length;
          final returnedCount = foundItems
              .where((item) => item['status'] == 'claimed')
              .length;
          final returnRate = foundCount == 0
              ? 0
              : (returnedCount / foundCount * 100).round();

          return Row(
            children: [
              Expanded(
                child: _Stat(
                  value: '$lostCount',
                  label: 'Items Lost',
                ),
              ),

              const _Divider(),

              Expanded(
                child: _Stat(
                  value: '$foundCount',
                  label: 'Items Found',
                  orange: true,
                ),
              ),

              const _Divider(),

              Expanded(
                child: _Stat(
                  value: '$returnRate%',
                  label: 'Return Rate',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool orange;

  const _Stat({
    required this.value,
    required this.label,
    this.orange = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: orange
                ? AppTheme.orange
                : isDark
                    ? Colors.white
                    : AppTheme.navy,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40,
      width: 1,
      color: isDark
          ? Colors.white.withOpacity(0.12)
          : AppTheme.border,
    );
  }
}
