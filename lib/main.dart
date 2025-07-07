import 'package:flutter/material.dart';
import 'models/friend.dart';
import 'screens/add_edit_friend_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'services/calendar_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';

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
          background: const Color(0xFFFAFAFA),
          surface: Colors.white,
          error: const Color(0xFFD32F2F),
          onPrimary: Colors.white,
          onBackground: const Color(0xFF1A1A1A),
          onSurface: const Color(0xFF1A1A1A),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF009688),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF009688),
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF009688), width: 2),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFF009688),
          labelTextStyle: MaterialStatePropertyAll(
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
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

  Future<void> syncFriendsWithCalendar() async {
    if (_currentUser == null) return;
    final calendarService = CalendarService(_currentUser!);
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeScreen(),
          _buildFriendsScreen(),
          _buildProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    final suggestedContacts = _getSuggestedContacts();
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Circles',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF009688), Color(0xFF00796B)],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildHighlightsSection(suggestedContacts),
                const SizedBox(height: 24),
                _buildQuickActionsSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Keep your relationships strong',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(List<Friend> suggestedContacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Highlights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_currentUser != null) ...[
          if (_loadingEvents)
            const Center(child: CircularProgressIndicator())
          else if (_upcomingCirclesEvents.isEmpty)
            _buildEmptyState(
              icon: Icons.check_circle_outline,
              title: 'All caught up!',
              subtitle: 'No upcoming Circles events',
              color: Colors.green,
            )
          else
            ..._upcomingCirclesEvents.map((event) {
              final start = event.start?.dateTime ?? event.start?.date;
              final dateStr = start != null ? DateFormat('EEE, MMM d').format(start.toLocal()) : '';
              final timeStr = start != null && event.start?.dateTime != null ? DateFormat('h:mm a').format(start.toLocal()) : '';
              return _buildEventCard(event, dateStr, timeStr);
            }),
        ] else
          _buildEmptyState(
            icon: Icons.info_outline,
            title: 'Sign in to see your Circles events',
            subtitle: 'Connect your Google account to get started',
            color: Colors.grey,
          ),
      ],
    );
  }

  Widget _buildEventCard(calendar.Event event, String dateStr, String timeStr) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.event,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          event.summary ?? 'Circles Event',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$dateStr${timeStr.isNotEmpty ? ' • $timeStr' : ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: event.htmlLink != null
              ? () async {
                  try {
                    final uri = Uri.parse(event.htmlLink!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      // Fallback to general calendar URL
                      final fallbackUri = Uri.parse('https://calendar.google.com/calendar/u/0/r');
                      if (await canLaunchUrl(fallbackUri)) {
                        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
                      }
                    }
                  } catch (e) {
                    // If all else fails, show a message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open calendar. Please open Google Calendar manually.'),
                        ),
                      );
                    }
                  }
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.person_add,
                title: 'Add Friend',
                subtitle: 'Add someone new',
                onTap: _addFriend,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.calendar_today,
                title: 'View Calendar',
                subtitle: 'See all events',
                onTap: _openGoogleCalendar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: _friends.isEmpty
          ? _buildEmptyState(
              icon: Icons.people_outline,
              title: 'No friends yet',
              subtitle: 'Add your first friend to get started',
              color: Colors.grey,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return _buildFriendCard(friend);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFriend,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    final daysSinceLastContact = friend.lastContacted != null
        ? DateTime.now().difference(friend.lastContacted!).inDays
        : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getTierColor(friend.closenessTier),
          child: Text(
            friend.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          friend.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTierLabel(friend.closenessTier),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (daysSinceLastContact != null)
              Text(
                'Last contacted ${_formatDaysAgo(daysSinceLastContact)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getUrgencyColor(daysSinceLastContact, friend.closenessTier),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'contact',
              child: Row(
                children: [
                  Icon(Icons.message),
                  SizedBox(width: 8),
                  Text('Contact'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editFriend(friend);
            } else if (value == 'contact') {
              // TODO: Implement contact action
            }
          },
        ),
        onTap: () => _editFriend(friend),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _currentUser?.photoUrl != null
                        ? NetworkImage(_currentUser!.photoUrl!)
                        : null,
                    backgroundColor: _currentUser == null
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.primary,
                    child: _currentUser == null
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser?.displayName ?? 'Not signed in',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_currentUser?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _currentUser!.email!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_currentUser != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: _handleSignOut,
              ),
            )
          else
            Card(
              child: ListTile(
                leading: const Icon(Icons.login, color: Color(0xFF009688)),
                title: const Text(
                  'Sign In',
                  style: TextStyle(color: Color(0xFF009688)),
                ),
                onTap: _handleSignIn,
              ),
            ),
        ],
      ),
    );
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
        return const Color(0xFF4CAF50);
      case ClosenessTier.medium:
        return const Color(0xFFFF9800);
      case ClosenessTier.distant:
        return const Color(0xFF2196F3);
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

  Future<void> _openGoogleCalendar() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to view your calendar'),
          action: SnackBarAction(
            label: 'Sign In',
            onPressed: () => _handleSignIn(),
          ),
        ),
      );
      return;
    }

    if (Platform.isAndroid) {
      // Try to open Google Calendar app using Android Intent
      try {
        final AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: 'https://calendar.google.com/calendar/u/0/r',
          package: 'com.google.android.calendar',
        );
        await intent.launch();
        return;
      } catch (e) {
        // If Google Calendar app fails, try default calendar
        try {
          final AndroidIntent intent = AndroidIntent(
            action: 'action_view',
            data: 'content://com.android.calendar/time',
          );
          await intent.launch();
          return;
        } catch (e) {
          // If both fail, show options dialog
        }
      }
    }

    // Fallback to URL launcher methods
    bool launched = false;
    
    // Try Google Calendar app URL
    try {
      final calendarAppUri = Uri.parse('https://calendar.google.com/calendar/u/0/r');
      if (await canLaunchUrl(calendarAppUri)) {
        await launchUrl(calendarAppUri, mode: LaunchMode.externalNonBrowserApplication);
        launched = true;
      }
    } catch (e) {
      // Continue to next method
    }
    
    // If that didn't work, show options dialog
    if (!launched && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Open Google Calendar'),
          content: const Text(
            'Choose how to open your calendar:\n\n'
            '• Try to open Google Calendar app\n'
            '• Open in browser\n'
            '• Open default calendar app'
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (Platform.isAndroid) {
                  try {
                    final AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: 'https://calendar.google.com/calendar/u/0/r',
                      package: 'com.google.android.calendar',
                    );
                    await intent.launch();
                  } catch (e) {
                    // Fallback to URL
                    launchUrl(
                      Uri.parse('https://calendar.google.com/calendar/u/0/r'),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }
              },
              child: const Text('Calendar App'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                launchUrl(
                  Uri.parse('https://calendar.google.com/calendar/u/0/r'),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: const Text('Browser'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (Platform.isAndroid) {
                  try {
                    final AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: 'content://com.android.calendar/time',
                    );
                    await intent.launch();
                  } catch (e) {
                    // Fallback to URL
                    launchUrl(
                      Uri.parse('content://com.android.calendar/time'),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                }
              },
              child: const Text('Default Calendar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }
}
