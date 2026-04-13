import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Altere para o IP da sua máquina se estiver testando em dispositivo físico.
  // Para emuladores Android, '10.0.2.2' geralmente aponta para o localhost da máquina host.
  // Para simuladores iOS, 'localhost' ou '127.0.0.1' funcionam.
  static const String _baseUrl = 'http://192.168.0.126:3000';

  static Future<Map<String, dynamic>> registerUser(
    String nome,
    String cpf,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nome': nome,
        'cpf': cpf,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true, 'message': jsonDecode(response.body)['message']};
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'],
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'token': jsonDecode(response.body)['token']};
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'],
      };
    }
  }
}
