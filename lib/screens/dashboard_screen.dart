import 'package:flutter/material.dart';
import '../models/friend.dart';

class DashboardScreen extends StatelessWidget {
  final List<Friend> friends;

  const DashboardScreen({super.key, required this.friends});

  List<Friend> _getSuggestedContacts() {
    final now = DateTime.now();
    return friends.where((friend) {
      if (friend.lastContacted == null) return true;
      
      final daysSinceLastContact = now.difference(friend.lastContacted!).inDays;
      
      switch (friend.closenessTier) {
        case ClosenessTier.close:
          return daysSinceLastContact >= 7; // Weekly check-ins
        case ClosenessTier.medium:
          return daysSinceLastContact >= 30; // Monthly check-ins
        case ClosenessTier.distant:
          return daysSinceLastContact >= 60; // Every 2-3 months
      }
    }).toList()
      ..sort((a, b) {
        // Sort by closeness tier first (close > medium > distant)
        final tierComparison = a.closenessTier.index.compareTo(b.closenessTier.index);
        if (tierComparison != 0) return tierComparison;
        
        // Then by last contacted date (most recent last)
        if (a.lastContacted == null && b.lastContacted == null) return 0;
        if (a.lastContacted == null) return -1;
        if (b.lastContacted == null) return 1;
        return a.lastContacted!.compareTo(b.lastContacted!);
      });
  }

  @override
  Widget build(BuildContext context) {
    final suggestedContacts = _getSuggestedContacts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: suggestedContacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All caught up!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re maintaining all your relationships well',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: suggestedContacts.length,
              itemBuilder: (context, index) {
                final friend = suggestedContacts[index];
                final daysSinceLastContact = friend.lastContacted != null
                    ? DateTime.now().difference(friend.lastContacted!).inDays
                    : null;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTierColor(friend.closenessTier),
                      child: Text(
                        friend.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
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
                  ),
                );
              },
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
} 