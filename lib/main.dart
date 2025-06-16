import 'package:flutter/material.dart';
import 'models/friend.dart';
import 'screens/add_edit_friend_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/calendar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

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
          seedColor: const Color(0xFF009688), // Teal
          brightness: Brightness.light,
          primary: const Color(0xFF009688),
          secondary: const Color(0xFFFF9800), // Orange accent
          background: const Color(0xFFF5F5F5),
          surface: Colors.white,
          error: const Color(0xFFD32F2F),
          onPrimary: Colors.white,
          onBackground: Colors.black87,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF009688),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF009688),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF009688),
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
    ],
  );
  GoogleSignInAccount? _currentUser;
  List<calendar.Event> _upcomingCirclesEvents = [];
  bool _loadingEvents = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (account != null) {
        _fetchUpcomingCirclesEvents();
        syncFriendsWithCalendar();
      } else {
        setState(() {
          _upcomingCirclesEvents = [];
        });
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      // Optionally show error
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.disconnect();
  }

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
      await _maybeCreateCalendarEvent(newFriend);
    }
  }

  Future<void> _editFriend(Friend friend) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditFriendScreen(friend: friend),
      ),
    );
    if (result is Friend) {
      final oldTier = friend.closenessTier;
      setState(() {
        final idx = _friends.indexWhere((f) => f.id == result.id);
        if (idx != -1) {
          _friends[idx] = result;
        }
      });
      if (oldTier != result.closenessTier) {
        await _maybeCreateCalendarEvent(result);
      }
    } else if (result is Map && result['delete'] == true && result['id'] != null) {
      setState(() {
        _friends.removeWhere((f) => f.id == result['id']);
      });
    }
  }

  /// Temporary sync: For each friend, if no Circles event exists, create one.
  /// In the future, this can use a database instead of the in-memory list.
  Future<void> syncFriendsWithCalendar() async {
    if (_currentUser == null) return;
    final calendarService = CalendarService(_currentUser!);
    // Fetch all upcoming Circles events (for all friends)
    final events = await calendarService.fetchUpcomingCirclesEvents(maxResults: 100);
    for (final friend in _friends) {
      final hasEvent = events.any((event) =>
        event.summary == 'Check in with ${friend.name}'
      );
      if (!hasEvent) {
        await calendarService.createRecurringCheckInEvent(
          friend: friend,
          start: _getFirstEventDate(friend.closenessTier),
        );
      }
    }
    await _fetchUpcomingCirclesEvents();
  }

  Future<void> _maybeCreateCalendarEvent(Friend friend) async {
    if (_currentUser == null) return;
    final calendarService = CalendarService(_currentUser!);
    final DateTime start = _getFirstEventDate(friend.closenessTier);
    final link = await calendarService.createRecurringCheckInEvent(friend: friend, start: start);
    if (link != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recurring check-in event created for ${friend.name}'),
          action: SnackBarAction(
            label: 'View/Edit',
            onPressed: () async {
              final uri = Uri.parse(link);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ),
      );
    }
    // Always refresh highlights after event creation
    await _fetchUpcomingCirclesEvents();
  }

  DateTime _getFirstEventDate(ClosenessTier tier) {
    final now = DateTime.now();
    switch (tier) {
      case ClosenessTier.close:
        return now.add(const Duration(days: 7));
      case ClosenessTier.medium:
        return now.add(const Duration(days: 30));
      case ClosenessTier.distant:
        return now.add(const Duration(days: 60));
    }
  }

  Future<void> _fetchUpcomingCirclesEvents() async {
    if (_currentUser == null) return;
    setState(() {
      _loadingEvents = true;
    });
    final calendarService = CalendarService(_currentUser!);
    final events = await calendarService.fetchUpcomingCirclesEvents(maxResults: 3);
    setState(() {
      _upcomingCirclesEvents = events;
      _loadingEvents = false;
    });
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () async {
                if (_currentUser == null) {
                  await _handleSignIn();
                } else {
                  await _handleSignOut();
                }
              },
              child: _currentUser == null
                  ? const Icon(Icons.person_outline, color: Colors.grey)
                  : CircleAvatar(
                      backgroundImage: NetworkImage(_currentUser!.photoUrl ?? ''),
                      backgroundColor: Colors.transparent,
                    ),
            ),
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
                if (_currentUser != null)
                  _loadingEvents
                      ? const Center(child: CircularProgressIndicator())
                      : _upcomingCirclesEvents.isEmpty
                          ? Row(
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                                const SizedBox(width: 8),
                                Text('No upcoming Circles events!', style: Theme.of(context).textTheme.bodyLarge),
                              ],
                            )
                          : Column(
                              children: _upcomingCirclesEvents.map((event) {
                                final start = event.start?.dateTime ?? event.start?.date;
                                final dateStr = start != null ? DateFormat('EEE, MMM d').format(start.toLocal()) : '';
                                final timeStr = start != null && event.start?.dateTime != null ? DateFormat('h:mm a').format(start.toLocal()) : '';
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: const Icon(Icons.event, color: Color(0xFF1976D2)),
                                    title: Text(event.summary ?? 'Circles Event'),
                                    subtitle: Text('$dateStr${timeStr.isNotEmpty ? ' • $timeStr' : ''}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: event.htmlLink != null
                                          ? () async {
                                              final uri = Uri.parse(event.htmlLink!);
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                if (_currentUser == null)
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey, size: 28),
                      const SizedBox(width: 8),
                      Text('Sign in to see your Circles events', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                const SizedBox(height: 16),
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
