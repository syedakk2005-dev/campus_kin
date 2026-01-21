import 'package:flutter/material.dart';
import 'package:campus_kin/models/item_model.dart';
import 'package:campus_kin/services/database_service.dart';
import 'package:campus_kin/widgets/item_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  List<ItemModel> _searchResults = [];
  String _selectedCategory = 'All Categories';
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRecentItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await DatabaseService.getAllItems();
      items.sort((a, b) => b.datePosted.compareTo(a.datePosted));
      setState(() {
        _searchResults = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    
    try {
      final query = _searchController.text.trim();
      final category = _selectedCategory == 'All Categories' ? null : _selectedCategory;
      
      ItemType? type;
      if (_tabController.index == 1) type = ItemType.lost;
      if (_tabController.index == 2) type = ItemType.found;
      
      final results = await DatabaseService.searchItems(query, type: type, category: category);
      results.sort((a, b) => b.datePosted.compareTo(a.datePosted));
      
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _selectedCategory = 'All Categories';
    });
    _loadRecentItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Items'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _performSearch(),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search header
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for items...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _performSearch(),
                ),
                
                const SizedBox(height: 12),
                
                // Category filter
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All Categories', ...ItemCategories.categories].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                            _performSearch();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _performSearch,
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasSearched ? Icons.search_off : Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _hasSearched ? 'No items found' : 'Search for lost or found items',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          if (_hasSearched)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Try different keywords or check other categories',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Column(
      children: [
        // Results count
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[100],
          child: Text(
            '${_searchResults.length} ${_searchResults.length == 1 ? 'item' : 'items'} found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ItemCard(
                  item: _searchResults[index],
                  onTap: () => _performSearch(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}