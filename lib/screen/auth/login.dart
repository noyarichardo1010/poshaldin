import 'dart:async';
import 'package:flutter/material.dart';
import 'package:protopos/assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:protopos/controller/login/login.dart';
import 'components/field.dart';

bool isFound = false;
// bool _obscureText = true;

// final RoundedLoadingButtonController _btnController1 =
//     RoundedLoadingButtonController();

final emailController = TextEditingController(text: '');
final passwordController = TextEditingController(text: '');

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

LoginRepo repository = LoginRepo();

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  checkToken() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    final String? urlKey = prefsAuth.getString('keylogin');
    if (urlKey == null) {
      // print('empty');
    } else {
      // print('exist');
    }
    print('PRINT Login Data ==  $urlKey');
  }

  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');
  // final context = TextEditingController(text: '');
  var validate;
  String? tokenKey;

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

    // redirectPage();
    checkToken();
    setState(() {});
    // togglePassword();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logo/logo_400.png',
                          fit: BoxFit.contain,
                          height: 60,
                          alignment: Alignment.topLeft,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      "Welcome Back!",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Center(
                    child: Text(
                      "Please Login with Your registered account",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xff919BA1),
                              content: Text('Loading...'),
                            ),
                          );

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) {
                              return const Dialog(
                                backgroundColor: Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: whiteColor,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Please wait...',
                                        style: TextStyle(color: whiteColor),
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
                                backgroundColor: errorColor,
                                content: Text(result['message']),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
