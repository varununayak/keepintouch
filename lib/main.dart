import 'package:flutter/material.dart';
import 'models/friend.dart';
import 'screens/add_edit_friend_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  List<Friend> _getSuggestedContacts() {
    final now = DateTime.now();
    return _friends.where((friend) {
      if (friend.lastContacted == null) return true;
      final daysSinceLastContact = now.difference(friend.lastContacted!).inDays;
      switch (friend.closenessTier) {
        case ClosenessTier.close:
          return daysSinceLastContact >= 7;
        case ClosenessTier.medium:
          return daysSinceLastContact >= 30;
        case ClosenessTier.distant:
          return daysSinceLastContact >= 60;
      }
    }).toList()
      ..sort((a, b) {
        final tierComparison = a.closenessTier.index.compareTo(b.closenessTier.index);
        if (tierComparison != 0) return tierComparison;
        if (a.lastContacted == null && b.lastContacted == null) return 0;
        if (a.lastContacted == null) return -1;
        if (b.lastContacted == null) return 1;
        return a.lastContacted!.compareTo(b.lastContacted!);
      });
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

  String _formatDaysAgo(int days) {
    if (days == 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    final months = (days / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  }

  Color _getUrgencyColor(int daysSinceLastContact, ClosenessTier tier) {
    final threshold = switch (tier) {
      ClosenessTier.close => 7,
      ClosenessTier.medium => 30,
      ClosenessTier.distant => 60,
    };
    if (daysSinceLastContact >= threshold * 2) {
      return Colors.red;
    } else if (daysSinceLastContact >= threshold) {
      return Colors.orange;
    }
    return Colors.green;
  }

  Future<void> _addFriend() async {
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
  }

  Future<void> _editFriend(Friend friend) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final suggestedContacts = _getSuggestedContacts();
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Dashboard Highlights Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Highlights', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (suggestedContacts.isEmpty)
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                      const SizedBox(width: 8),
                      Text('All caught up!', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  )
                else
                  ...suggestedContacts.take(3).map((friend) {
                    final daysSinceLastContact = friend.lastContacted != null
                        ? DateTime.now().difference(friend.lastContacted!).inDays
                        : null;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getTierColor(friend.closenessTier),
                          child: Text(friend.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(friend.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getTierLabel(friend.closenessTier)),
                            if (daysSinceLastContact != null)
                              Text(
                                'Last contacted ${_formatDaysAgo(daysSinceLastContact)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _getUrgencyColor(daysSinceLastContact, friend.closenessTier),
                                    ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            // TODO: Implement quick contact action
                          },
                        ),
                        onTap: () => _editFriend(friend),
                      ),
                    );
                  }),
                if (suggestedContacts.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('+${suggestedContacts.length - 3} more suggestions', style: Theme.of(context).textTheme.bodySmall),
                  ),
              ],
            ),
          ),
          const Divider(),
          // Friends List Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('All Friends', style: Theme.of(context).textTheme.titleMedium),
          ),
          if (_friends.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No friends added yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Tap the + button to add your first friend', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            )
          else
            ..._friends.map((friend) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getTierColor(friend.closenessTier),
                    child: Text(friend.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(friend.name),
                  subtitle: Text(_getTierLabel(friend.closenessTier)),
                  trailing: Text(
                    friend.lastContacted != null ? _formatDaysAgo(DateTime.now().difference(friend.lastContacted!).inDays) : 'Never',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => _editFriend(friend),
                )),
          const SizedBox(height: 80), // For FAB spacing
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFriend,
        child: const Icon(Icons.add),
      ),
    );
  }
}
