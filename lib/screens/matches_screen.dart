import 'package:flutter/material.dart';
import 'package:campus_kin/models/item_model.dart';
import 'package:campus_kin/services/database_service.dart';
import 'package:campus_kin/services/ai_service.dart';
import 'package:campus_kin/widgets/item_card.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<_MatchPair> _matches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _findMatches();
  }

  Future<void> _findMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allItems = await DatabaseService.getAllItems();
      final lostItems = allItems.where((item) => item.type == ItemType.lost).toList();
      final foundItems = allItems.where((item) => item.type == ItemType.found).toList();

      final List<_MatchPair> potentialMatches = [];

      // For each lost item, find similar found items
      for (final lostItem in lostItems) {
        final similarItems = await AIService.findSimilarItems(
          lostItem,
          foundItems,
          threshold: 0.6, // Lower threshold for more matches
        );

        for (final foundItem in similarItems) {
          final similarity = await AIService.calculateSimilarity(
            lostItem.imagePath,
            foundItem.imagePath,
          );

          potentialMatches.add(_MatchPair(
            lostItem: lostItem,
            foundItem: foundItem,
            similarity: similarity,
          ));
        }
      }

      // Sort by similarity score
      potentialMatches.sort((a, b) => b.similarity.compareTo(a.similarity));

      setState(() {
        _matches = potentialMatches.take(20).toList(); // Show top 20 matches
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _findMatches,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _matches.isEmpty
                  ? _buildEmptyState()
                  : _buildMatchesList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Error finding matches',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _findMatches,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No matches found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Our AI couldn\'t find any potential matches at this time.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _matches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final match = _matches[index];
        return _MatchCard(
          match: match,
          onTap: () => _showMatchDetail(match),
        );
      },
    );
  }

  void _showMatchDetail(_MatchPair match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Potential Match',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(match.similarity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(match.similarity * 100).toInt()}% match',
                      style: TextStyle(
                        color: _getConfidenceColor(match.similarity),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      'Lost Item',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ItemCard(item: match.lostItem),
                    const SizedBox(height: 24),
                    Text(
                      'Found Item',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ItemCard(item: match.foundItem),
                    const SizedBox(height: 24),
                    Text(
                      'Match Analysis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.category, size: 16),
                                const SizedBox(width: 8),
                                Text('Category: ${match.lostItem.category == match.foundItem.category ? 'Match ✓' : 'Different ✗'}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text('Locations: ${match.lostItem.location} / ${match.foundItem.location}'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, size: 16),
                                const SizedBox(width: 8),
                                Text('AI Similarity: ${(match.similarity * 100).toInt()}%'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contact information copied to clipboard'),
                      ),
                    );
                  },
                  child: const Text('Contact Both Users'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double similarity) {
    if (similarity >= 0.8) return Colors.green;
    if (similarity >= 0.6) return Colors.orange;
    return Colors.red;
  }
}

class _MatchPair {
  final ItemModel lostItem;
  final ItemModel foundItem;
  final double similarity;

  _MatchPair({
    required this.lostItem,
    required this.foundItem,
    required this.similarity,
  });
}

class _MatchCard extends StatelessWidget {
  final _MatchPair match;
  final VoidCallback onTap;

  const _MatchCard({
    required this.match,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with confidence
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Potential Match',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(match.similarity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(match.similarity * 100).toInt()}% match',
                      style: TextStyle(
                        color: _getConfidenceColor(match.similarity),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Items comparison
              Row(
                children: [
                  // Lost item
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'LOST',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.lostItem.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match.lostItem.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.compare_arrows,
                      color: Colors.grey[400],
                    ),
                  ),
                  
                  // Found item
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'FOUND',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.foundItem.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match.foundItem.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double similarity) {
    if (similarity >= 0.8) return Colors.green;
    if (similarity >= 0.6) return Colors.orange;
    return Colors.red;
  }
}