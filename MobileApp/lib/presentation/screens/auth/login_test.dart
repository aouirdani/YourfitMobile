import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url =
      Uri.parse('https://yourfitmobile-production.up.railway.app/auth/login');

  final body = jsonEncode({
    'email': 'aymane@mail.com',
    'password': 'Test1234', // mot de passe utilisé lors du signup
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Login successful!');
      print('User ID: ${data['user']['id']}');
      print('Token: ${data['token']}');
    } else {
      print('❌ Login failed: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('❌ HTTP Error: $e');
  }
}
