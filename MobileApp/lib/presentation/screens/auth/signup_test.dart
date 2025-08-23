import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final String baseUrl = 'https://yourfitmobile-production.up.railway.app';

  final signupData = {
    "name": "Aymane",
    "age": 31,
    "gender": "male",
    "weight": 75.0,
    "height": 180.0,
    "targetWeight": 70.0,
    "fitnessGoal": "lose_weight",
    "weeklyGoal": "0.5",
    "activityLevel": "moderate",
    "dietRestrictions": ["gluten_free"],
    "foodPreferences": ["chicken", "rice"],
    "email": "aymane@mail.com",
    "password": "Test1234"
  };

  final response = await http.post(
    Uri.parse('$baseUrl/auth/signup'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(signupData),
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    if (body['success'] == true) {
      print('✅ Account created successfully!');
      print('Token: ${body['token']}');
    } else {
      print('❌ Signup failed: ${body}');
    }
  } else {
    print('❌ HTTP Error: ${response.statusCode}');
    print(response.body);
  }
}
