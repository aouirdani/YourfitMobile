import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final Map<String, dynamic>? user;

  AuthState({this.isAuthenticated = false, this.token, this.user});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      final token = response.data['token'];
      final user = response.data['user'];

      await ApiService.storage.write(key: 'auth_token', value: token);

      state = AuthState(isAuthenticated: true, token: token, user: user);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    await ApiService.storage.delete(key: 'auth_token');
    state = AuthState();
  }
}

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiServiceProvider));
});
