import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android)
      return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  static Future<Map<String, dynamic>> registerUser(
    String nome,
    String cpf,
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'nome': nome,
          'cpf': cpf,
          'email': email,
          'password': password,
        }),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 201
          ? {'success': true, 'message': body['message']}
          : {'success': false, 'message': body['message']};
    } catch (_) {
      return {'success': false, 'message': 'Erro de conexão com o servidor.'};
    }
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final body = jsonDecode(res.body);
      return res.statusCode == 200
          ? {'success': true, 'token': body['token']}
          : {'success': false, 'message': body['message']};
    } catch (_) {
      return {'success': false, 'message': 'Erro de conexão com o servidor.'};
    }
  }
}
