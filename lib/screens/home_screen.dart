import 'package:flutter/material.dart';
import 'package:campus_kin/models/item_model.dart';
import 'package:campus_kin/services/database_service.dart';
import 'package:campus_kin/services/sample_data_service.dart';
import 'package:campus_kin/screens/post_item_screen.dart';
import 'package:campus_kin/screens/search_screen.dart';
import 'package:campus_kin/screens/matches_screen.dart';
import 'package:campus_kin/widgets/item_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ItemModel> _recentItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await DatabaseService.init();
    await SampleDataService.loadSampleData();
    await _loadRecentItems();
  }

  Future<void> _loadRecentItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await DatabaseService.getAllItems();
      items.sort((a, b) => b.datePosted.compareTo(a.datePosted));
      setState(() {
        _recentItems = items.take(10).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading items: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Kin'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ).then((_) => _loadRecentItems()),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadRecentItems,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                title: 'Post Lost Item',
                                icon: Icons.search_off,
                                color: Theme.of(context).colorScheme.tertiary,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PostItemScreen(type: ItemType.lost),
                                  ),
                                ).then((_) => _loadRecentItems()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _QuickActionCard(
                                title: 'Post Found Item',
                                icon: Icons.search,
                                color: Theme.of(context).colorScheme.secondary,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PostItemScreen(type: ItemType.found),
                                  ),
                                ).then((_) => _loadRecentItems()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Items',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MatchesScreen()),
                              ),
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('AI Matches'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_recentItems.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No items yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Be the first to post something!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ItemCard(
                            item: _recentItems[index],
                            onTap: () => _loadRecentItems(),
                          ),
                        ),
                        childCount: _recentItems.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ).then((_) => _loadRecentItems()),
        icon: const Icon(Icons.search),
        label: const Text('Search'),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}