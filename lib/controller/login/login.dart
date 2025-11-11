import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:poshaldin/const.dart';

class loginRepo {
  final _baseurl = baseUrl;
  Future<Map<String, dynamic>> getToken(dynamic _userName, _password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseurl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _userName, 'password': _password}),
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        print('PRINT LOGIN RESPONSE $responseBody');

        return {'success': true, 'login_url': responseBody['login_url']};
      } else {
        return {
          'success': false,
          'message':
              responseBody['message'] ??
              'Please Check Again, Wrong Email / password',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
