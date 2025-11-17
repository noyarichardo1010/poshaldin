import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:protopos/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRepo {
  String? keyLogin;
  final _baseurl = baseUrl;
  Future<Map<String, dynamic>> getToken(dynamic _userName, _password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseurl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _userName, 'password': _password}),
      );
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        var itemAuth = responseBody;
        debugPrint('PRINT LOGIN RESPONSE $itemAuth');
        final SharedPreferences prefsAuth =
            await SharedPreferences.getInstance();
        await prefsAuth.setString('keylogin', itemAuth['login_url']);

        // final List<String>? testprintdatalogin = prefsAuth.getStringList(
        //   'keylogin',
        // );
        keyLogin = prefsAuth.getString('keylogin');

        debugPrint('TEST PRINT DATA LOGIN ==== ${keyLogin}');

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
      debugPrint(e.toString());
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
