import 'package:flutter/material.dart';
import '../models/friend.dart';
import 'add_edit_friend_screen.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  // Temporary list for development - will be replaced with proper state management
  final List<Friend> _friends = [
    Friend(
      id: '1',
      name: 'John Doe',
      closenessTier: ClosenessTier.close,
      notes: 'College roommate',
      lastContacted: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Friend(
      id: '2',
      name: 'Jane Smith',
      closenessTier: ClosenessTier.medium,
      notes: 'Work colleague',
      lastContacted: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Friend(
      id: '3',
      name: 'Mike Johnson',
      closenessTier: ClosenessTier.distant,
      notes: 'High school friend',
      lastContacted: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: _friends.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No friends added yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first friend',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTierColor(friend.closenessTier),
                    child: Text(
                      friend.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(friend.name),
                  subtitle: Text(_getTierLabel(friend.closenessTier)),
                  trailing: Text(
                    friend.lastContacted != null
                        ? _formatLastContacted(friend.lastContacted!)
                        : 'Never',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditFriendScreen(friend: friend),
                      ),
                    );
                    if (result is Friend) {
                      setState(() {
                        final idx = _friends.indexWhere((f) => f.id == result.id);
                        if (idx != -1) {
                          _friends[idx] = result;
                        }
                      });
                    } else if (result is Map && result['delete'] == true && result['id'] != null) {
                      setState(() {
                        _friends.removeWhere((f) => f.id == result['id']);
                      });
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newFriend = await Navigator.of(context).push<Friend>(
            MaterialPageRoute(
              builder: (context) => const AddEditFriendScreen(),
            ),
          );
          if (newFriend != null) {
            setState(() {
              _friends.add(newFriend);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTierColor(ClosenessTier tier) {
    switch (tier) {
      case ClosenessTier.close:
        return Colors.green;
      case ClosenessTier.medium:
        return Colors.orange;
      case ClosenessTier.distant:
        return Colors.blue;
    }
  }

  String _getTierLabel(ClosenessTier tier) {
    switch (tier) {
      case ClosenessTier.close:
        return 'Close - Weekly check-ins';
      case ClosenessTier.medium:
        return 'Medium - Monthly check-ins';
      case ClosenessTier.distant:
        return 'Distant - Every 2-3 months';
    }
  }

  String _formatLastContacted(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }
  }
} 