import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

class EventsService {
  EventsService._();
  static final EventsService instance = EventsService._();

  Future<List<Map<String, dynamic>>> getEvents({
    required String status,
    int page = 1,
    int perPage = 10,
    String? city,
    String? format,
    String? query,
  }) async {
    final qp = <String, String>{
      'status': status,
      'page': '$page',
      'per_page': '$perPage',
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
      if (format != null && format.trim().isNotEmpty) 'format': format.trim(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };
    final candidates = <String>[
      ApiEndpoints.events,
      '${ApiEndpoints.baseUrl}/events-exhibitions',
      '${ApiEndpoints.baseUrl}/event-exhibitions',
    ];

    Exception? lastError;
    for (final endpoint in candidates) {
      final url = Uri.parse(endpoint).replace(queryParameters: qp).toString();
      try {
        final response = await ApiClient.instance.get(
          url,
          requireAuth: true,
          logTag: 'EventsService',
        );
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Failed to load events');
        }
        final data = response['data'];
        final items = data is Map && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : <dynamic>[]);
        return items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } on ApiException catch (e) {
        lastError = Exception(e.message);
        if (!_isRouteNotFound(e)) rethrow;
      } catch (e) {
        lastError = Exception(e.toString());
      }
    }
    throw lastError ?? Exception('Failed to load events');
  }

  Future<Map<String, dynamic>> getEventDetail(String eventId) async {
    final candidates = <String>[
      ApiEndpoints.event(eventId),
      '${ApiEndpoints.baseUrl}/events-exhibitions/$eventId',
      '${ApiEndpoints.baseUrl}/event-exhibitions/$eventId',
    ];
    Exception? lastError;
    for (final url in candidates) {
      try {
        final response = await ApiClient.instance.get(
          url,
          requireAuth: true,
          logTag: 'EventsService',
        );
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Failed to load event details');
        }
        final data = response['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        throw Exception('Invalid event details response');
      } on ApiException catch (e) {
        lastError = Exception(e.message);
        if (!_isRouteNotFound(e)) rethrow;
      } catch (e) {
        lastError = Exception(e.toString());
      }
    }
    throw lastError ?? Exception('Failed to load event details');
  }

  Future<Map<String, dynamic>> registerForEvent(
    String eventId, {
    String source = 'events_screen',
    String notes = '',
  }) async {
    final candidates = <String>[
      ApiEndpoints.eventRegistrations(eventId),
      '${ApiEndpoints.baseUrl}/events-exhibitions/$eventId/registrations',
      '${ApiEndpoints.baseUrl}/event-exhibitions/$eventId/registrations',
    ];
    Exception? lastError;
    for (final url in candidates) {
      try {
        final response = await ApiClient.instance.post(
          url,
          requireAuth: true,
          logTag: 'EventsService',
          body: {'source': source, 'notes': notes},
        );
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Registration failed');
        }
        final data = response['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      } on ApiException catch (e) {
        lastError = Exception(e.message);
        if (!_isRouteNotFound(e)) rethrow;
      } catch (e) {
        lastError = Exception(e.toString());
      }
    }
    throw lastError ?? Exception('Registration failed');
  }

  Future<Map<String, dynamic>> addToCalendar(
    String eventId, {
    String provider = 'google',
    String timezone = 'Africa/Cairo',
  }) async {
    final candidates = <String>[
      ApiEndpoints.eventCalendar(eventId),
      '${ApiEndpoints.baseUrl}/events-exhibitions/$eventId/calendar',
      '${ApiEndpoints.baseUrl}/event-exhibitions/$eventId/calendar',
    ];
    Exception? lastError;
    for (final url in candidates) {
      try {
        final response = await ApiClient.instance.post(
          url,
          requireAuth: true,
          logTag: 'EventsService',
          body: {'provider': provider, 'timezone': timezone},
        );
        if (response['success'] != true) {
          throw Exception(response['message'] ?? 'Calendar request failed');
        }
        final data = response['data'];
        if (data is Map<String, dynamic>) return data;
        if (data is Map) return Map<String, dynamic>.from(data);
        return <String, dynamic>{};
      } on ApiException catch (e) {
        lastError = Exception(e.message);
        if (!_isRouteNotFound(e)) rethrow;
      } catch (e) {
        lastError = Exception(e.toString());
      }
    }
    throw lastError ?? Exception('Calendar request failed');
  }

  Future<Map<String, dynamic>?> getHero() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.eventsHero,
        requireAuth: true,
        logTag: 'EventsService',
      );
      if (response['success'] != true) return null;
      final data = response['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
    return null;
  }

  bool _isRouteNotFound(ApiException e) {
    final msg = e.message.toLowerCase();
    final serverMsg = e.responseJson?['message']?.toString().toLowerCase() ?? '';
    return msg.contains('route not found') || serverMsg.contains('route not found');
  }

  static String pickLocalized(
    Map<String, dynamic> map,
    String baseKey,
    bool isAr, {
    String fallback = '',
  }) {
    final localized = isAr
        ? (map['${baseKey}_ar']?.toString() ?? map['${baseKey}Ar']?.toString())
        : (map['${baseKey}_en']?.toString() ??
            map['${baseKey}En']?.toString());
    if (localized != null && localized.trim().isNotEmpty) return localized.trim();
    final generic = map[baseKey]?.toString();
    if (generic != null && generic.trim().isNotEmpty) return generic.trim();
    return fallback;
  }
}

