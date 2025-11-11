import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:poshaldin/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class loginRepo {
  String? tokenLogin;
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
        var itemAuth = responseBody;
        print('PRINT LOGIN RESPONSE $itemAuth');
        final SharedPreferences prefsAuth =
            await SharedPreferences.getInstance();
        await prefsAuth.setString('tokenlogin', itemAuth['login_url']);

        // final List<String>? testprintdatalogin = prefsAuth.getStringList(
        //   'tokenlogin',
        // );
        tokenLogin = prefsAuth.getString('tokenlogin');

        print('TEST PRINT DATA LOGIN ==== ${tokenLogin}');

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
