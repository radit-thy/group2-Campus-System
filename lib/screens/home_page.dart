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
      body: IndexedStack(index: currentIndex, children: pages),

      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppTheme.orange,
              foregroundColor: AppTheme.navy,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportItemScreen()),
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
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,

            title: Row(
              children: [
                const Icon(Icons.school_outlined, color: AppTheme.navy),

                const SizedBox(width: 8),

                const Text(
                  'Campus Found',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            actions: [
              CircleAvatar(
                backgroundColor: AppTheme.lightBlue,
                child: Icon(Icons.person, color: AppTheme.navy),
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
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            title: 'REPORT LOST',
            icon: Icons.person_search,
            color: AppTheme.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportItemScreen(initialType: 'lost'),
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
            color: AppTheme.lightBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportItemScreen(initialType: 'found'),
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
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),

        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.navy,
              child: Icon(icon, color: Colors.white),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: .5,
                color: AppTheme.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
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
            const Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),

            TextButton(onPressed: () {}, child: const Text('View All')),
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
                        color: AppTheme.iconBlue,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),

                      child: Icon(
                        category['icon'] as IconData,
                        color: AppTheme.navy,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      category['name'] as String,
                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          'Recently Found',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
          ),
        ),

        const SizedBox(height: 12),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: ItemService().getFoundItems(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _emptyItems();
            }

            final docs = snapshot.data!.docs;

            return Column(
              children: docs
                  .take(4)
                  .map((doc) => _itemCard(context, doc))
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
    final data = doc.data();

    final imageUrl = data['imageUrl'] ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: doc.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),

          border: Border.all(color: AppTheme.border),

          boxShadow: const [
            BoxShadow(blurRadius: 4, color: Color.fromRGBO(0, 0, 0, .08)),
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
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

                        child: const Text(
                          'NEW MATCH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),

                      const SizedBox(width: 4),

                      Expanded(child: Text(data['location'] ?? '')),
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
                              content: Text('Item claimed successfully'),
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

  Widget _emptyItems() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(32),

      decoration: BoxDecoration(
        color: AppTheme.paleBlue,
        borderRadius: BorderRadius.circular(12),
      ),

      child: const Column(
        children: [
          Icon(Icons.search_off, size: 40, color: AppTheme.navy),

          SizedBox(height: 8),

          Text('No items found yet.'),
        ],
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),

      decoration: BoxDecoration(
        color: AppTheme.paleBlue,
        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: AppTheme.border),
      ),

      child: const Row(
        children: [
          Expanded(
            child: _Stat(value: '124', label: 'Items Lost'),
          ),

          _Divider(),

          Expanded(
            child: _Stat(value: '86', label: 'Items Found', orange: true),
          ),

          _Divider(),

          Expanded(
            child: _Stat(value: '92%', label: 'Return Rate'),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final bool orange;

  const _Stat({required this.value, required this.label, this.orange = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: orange ? const Color(0xFF875200) : AppTheme.navy,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 40, width: 1, color: AppTheme.border);
  }
}
