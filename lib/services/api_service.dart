// lib/services/api_service.dart
//
// The frontend runs with sample data by default. When the PHP API is
// ready, start Flutter with:
//
//   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
//
// 10.0.2.2 is the Android emulator's address for the computer's localhost.
// Never put database passwords or API secrets in Flutter source code.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/campus_task.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static bool get isConfigured => baseUrl.trim().isNotEmpty;

  final http.Client _client = http.Client();
  String? _token;

  void setAuthToken(String? token) {
    _token = token;
  }

  void clearAuthToken() {
    _token = null;
  }

  // ---------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> login({
    required String universityId,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login.php',
      body: {
        'university_id': universityId.trim(),
        'password': password,
      },
    );
    return _asMap(data, 'The login response was not valid.');
  }

  // ---------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchUsers({
    String? role,
    String? search,
  }) async {
    final data = await _request(
      'GET',
      '/users.php',
      query: {
        if (role != null && role.isNotEmpty) 'role': role,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> fetchUser(int userId) async {
    final data = await _request('GET', '/users.php', query: {'id': '$userId'});
    return _asMap(data, 'The user response was not valid.');
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) async {
    final data = await _request('POST', '/users.php', body: payload);
    return _asMap(data, 'The create-user response was not valid.');
  }

  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'PUT',
      '/users.php',
      query: {'id': '$userId'},
      body: payload,
    );
    return _asMap(data, 'The update-user response was not valid.');
  }

  Future<void> deactivateUser(int userId) async {
    await _request(
      'PATCH',
      '/users.php',
      query: {'id': '$userId', 'action': 'deactivate'},
    );
  }

  // ---------------------------------------------------------------
  // Tasks
  // ---------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchTasks(int studentId) async {
    final data = await _request(
      'GET',
      '/tasks.php',
      query: {'student_id': '$studentId'},
    );
    return _asMapList(data);
  }

  Future<Map<String, dynamic>> updateTaskStatus({
    required int taskId,
    required TaskStatus status,
  }) async {
    final data = await _request(
      'PATCH',
      '/tasks.php',
      query: {'id': '$taskId'},
      body: {'status': status.name},
    );
    return _asMap(data, 'The task response was not valid.');
  }

  Future<Map<String, dynamic>> createAssignment(
    Map<String, dynamic> payload,
  ) async {
    final data = await _request('POST', '/tasks.php', body: payload);
    return _asMap(data, 'The assignment response was not valid.');
  }

  // ---------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    return _asMapList(await _request('GET', '/events.php'));
  }

  Future<Map<String, dynamic>> createEvent(
    Map<String, dynamic> payload,
  ) async {
    final data = await _request('POST', '/events.php', body: payload);
    return _asMap(data, 'The event response was not valid.');
  }

  Future<Map<String, dynamic>> updateEvent(
    int eventId,
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'PUT',
      '/events.php',
      query: {'id': '$eventId'},
      body: payload,
    );
    return _asMap(data, 'The event response was not valid.');
  }

  Future<void> deleteEvent(int eventId) async {
    await _request('DELETE', '/events.php', query: {'id': '$eventId'});
  }

  // ---------------------------------------------------------------
  // Announcements
  // ---------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchAnnouncements() async {
    return _asMapList(await _request('GET', '/announcements.php'));
  }

  Future<Map<String, dynamic>> createAnnouncement(
    Map<String, dynamic> payload,
  ) async {
    final data = await _request('POST', '/announcements.php', body: payload);
    return _asMap(data, 'The announcement response was not valid.');
  }

  Future<Map<String, dynamic>> updateAnnouncement(
    int announcementId,
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'PUT',
      '/announcements.php',
      query: {'id': '$announcementId'},
      body: payload,
    );
    return _asMap(data, 'The announcement response was not valid.');
  }

  Future<void> deleteAnnouncement(int announcementId) async {
    await _request(
      'DELETE',
      '/announcements.php',
      query: {'id': '$announcementId'},
    );
  }

  // ---------------------------------------------------------------
  // Student profile
  // ---------------------------------------------------------------

  Future<Map<String, dynamic>> fetchStudentProfile(int userId) async {
    final data = await _request(
      'GET',
      '/student_profile.php',
      query: {'user_id': '$userId'},
    );
    return _asMap(data, 'The student profile response was not valid.');
  }

  Future<Map<String, dynamic>> updateStudentProfile(
    int userId,
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'PUT',
      '/student_profile.php',
      query: {'user_id': '$userId'},
      body: payload,
    );
    return _asMap(data, 'The student profile response was not valid.');
  }

  // ---------------------------------------------------------------
  // Shared HTTP helpers
  // ---------------------------------------------------------------

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    if (!isConfigured) {
      throw const ApiException(
        'The API is not configured. Run the app with sample data, or pass '
        'API_BASE_URL with --dart-define.',
      );
    }

    final uri = _buildUri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };

    late http.Response response;
    try {
      final encodedBody = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 15));
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 15));
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 15));
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 15));
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Cannot reach the server. Check your connection and API address.',
      );
    }

    dynamic decoded;
    if (response.body.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw ApiException(
          'The server returned an invalid response.',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var message = 'The request failed. Please try again.';
      if (decoded is Map) {
        final serverMessage = decoded['message'] ?? decoded['error'];
        if (serverMessage != null && '$serverMessage'.trim().isNotEmpty) {
          message = '$serverMessage';
        }
      }
      throw ApiException(message, statusCode: response.statusCode);
    }

    return decoded;
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$cleanBase$cleanPath');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  Map<String, dynamic> _asMap(dynamic data, String errorMessage) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException(errorMessage);
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    dynamic raw = data;
    if (raw is Map && raw['data'] is List) raw = raw['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
