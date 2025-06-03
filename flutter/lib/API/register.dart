import 'package:http/http.dart' as http;

import 'dart:convert';


class NewUser {
  const NewUser.create({
    this.username,
    this.password,
    this.password2,
    this.email,
    this.firstName,
    this.lastName,
  });
  final String? username;
  final String? password;
  final String? password2;
  final String? email;
  final String? firstName;
  final String? lastName;
  Future<NewUser> register() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'password2': password2,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );
    if (response.statusCode == 201) {
      return this;
    } else {
      final decoded = jsonDecode(response.body);

      final Map<String, List<String>> result = (decoded as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
      throw result;
      // сделать класс исключение
    }
  }
}
