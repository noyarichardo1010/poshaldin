import 'dart:async';
import 'package:flutter/material.dart';
import 'package:poshaldin/assets.dart';

import 'package:shared_preferences/shared_preferences.dart';

// import 'package:poshaldin/controller/repository.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:poshaldin/controller/login/login.dart';
import 'components/field.dart';

bool isFound = false;
bool _obscureText = true;

final RoundedLoadingButtonController _btnController1 =
    RoundedLoadingButtonController();

final emailController = TextEditingController(text: '');
final passwordController = TextEditingController(text: '');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

loginRepo repository = loginRepo();

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  void getTokenAdmin() async {
    // final responseAdminToken = await repositoryKey.getTokenAdmin();
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();

    // tokenKeyAdmin = prefsAuth.getString('tokenKeyAdmin');
    // await prefsAuth.remove('tokenKeyAdmin');
    // print('test print token Admin $tokenKeyAdmin');
  }

  checkToken() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    final String? tokenKey = prefsAuth.getString('tokenKey2');
    if (tokenKey == null) {
      // print('empty');
    } else {
      // print('exist');
    }
    // print('PRINT TOKEN $tokenKey');
  }

  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');
  // final context = TextEditingController(text: '');
  var validate;
  String? tokenKey;

  void _doSomething(RoundedLoadingButtonController controller) async {
    Timer(Duration(seconds: 5), () {
      controller.success();
      // CircularProgressIndicator(
      //   backgroundColor: Colors.amber,
      // );
      // Navigator.pushNamed(context, '/home');
      if (controller != true) {
        // print(controller);
        Navigator.pushNamed(context, '/home');
      } else {
        Navigator.pushNamed(context, '/login');
        // print(controller);
      }
    });
  }

  Future<Map<String, dynamic>> loginSetAuth() async {
    return await repository.getToken(
      emailController.text,
      passwordController.text,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getTokenAdmin();
    // redirectPage();
    checkToken();
    setState(() {});
    // togglePassword();
  }

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image.asset("assets/images/banner_login.png", fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Text(
                    "Welcome back!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Log in with your data that you intered during your registration.",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                  SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Color(0xff919BA1),
                              content: Text('Loading...'),
                            ),
                          );
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Please wait...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );

                          final result = await loginSetAuth();
                          Navigator.of(context).pop();

                          if (result['success']) {
                            Navigator.pushNamed(
                              context,
                              '/home',
                              arguments: result['login_url'],
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(result['message']),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 34, 3, 232),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
