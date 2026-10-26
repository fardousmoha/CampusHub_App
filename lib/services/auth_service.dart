// lib/services/auth_service.dart

import '../data/sample_data.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<User> login({
    required String universityId,
    required String password,
  }) async {
    if (ApiService.isConfigured) {
      return _loginWithApi(universityId: universityId, password: password);
    }

    // A short delay makes the loading state visible, like a real network call.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final user = CampusData.instance.userByUniversityId(universityId);
    if (user == null || user.password != password) {
      throw const AuthException(
        'Incorrect university ID or password. Please try again.',
      );
    }
    if (!user.isActive) {
      throw const AuthException(
        'This account has been deactivated. Contact the administration office.',
      );
    }

    _currentUser = user;
    return user;
  }

  Future<User> _loginWithApi({
    required String universityId,
    required String password,
  }) async {
    final response = await ApiService.instance.login(
      universityId: universityId,
      password: password,
    );

    final payload = response['data'] is Map
        ? Map<String, dynamic>.from(response['data'] as Map)
        : response;

    final rawUser = payload['user'];
    if (rawUser is! Map) {
      throw const AuthException(
        'The server response did not include a user account.',
      );
    }

    final user = User.fromJson(Map<String, dynamic>.from(rawUser));
    if (!user.isActive) {
      throw const AuthException(
        'This account has been deactivated. Contact the administration office.',
      );
    }

    final token = payload['token'];
    if (token is String && token.isNotEmpty) {
      ApiService.instance.setAuthToken(token);
    }

    _currentUser = user;
    return user;
  }

  void updateCurrentUser(User user) {
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
  }

  void logout() {
    _currentUser = null;
    ApiService.instance.clearAuthToken();
  }
}
