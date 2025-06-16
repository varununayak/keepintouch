import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/friend.dart';

class CalendarService {
  final GoogleSignInAccount account;

  CalendarService(this.account);

  Future<calendar.CalendarApi> _getCalendarApi() async {
    final authHeaders = await account.authHeaders;
    final client = _GoogleAuthClient(authHeaders);
    return calendar.CalendarApi(client);
  }

  Future<String?> createRecurringCheckInEvent({
    required Friend friend,
    required DateTime start,
  }) async {
    final api = await _getCalendarApi();
    final event = calendar.Event();
    event.summary = 'Check in with ${friend.name}';
    event.description = friend.notes;
    event.start = calendar.EventDateTime(dateTime: start, timeZone: 'UTC');
    event.end = calendar.EventDateTime(dateTime: start.add(const Duration(hours: 1)), timeZone: 'UTC');
    event.recurrence = [
      _recurrenceRule(friend.closenessTier),
    ];
    event.extendedProperties = calendar.EventExtendedProperties(
      private: {'circles': 'true'},
    );
    event.colorId = '7'; // Peacock/Blue
    final created = await api.events.insert(event, 'primary');
    return created.htmlLink; // Returns a link to view/edit the event
  }

  String _recurrenceRule(ClosenessTier tier) {
    switch (tier) {
      case ClosenessTier.close:
        return 'RRULE:FREQ=WEEKLY';
      case ClosenessTier.medium:
        return 'RRULE:FREQ=MONTHLY';
      case ClosenessTier.distant:
        return 'RRULE:FREQ=MONTHLY;INTERVAL=2';
    }
  }

  Future<List<calendar.Event>> fetchUpcomingCirclesEvents({int maxResults = 5}) async {
    final api = await _getCalendarApi();
    final now = DateTime.now().toUtc();
    final events = await api.events.list(
      'primary',
      timeMin: now,
      maxResults: maxResults,
      singleEvents: true,
      orderBy: 'startTime',
      privateExtendedProperty: ['circles=true'],
    );
    return events.items ?? [];
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = IOClient();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
} 