import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:protopos/assets.dart';

bool isFound = false;

class LogInForm extends StatefulWidget {
  const LogInForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _obscureText = true;

  void togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Container(
            // padding: EdgeInsets.only(top: 5, bottom: 10, left: 16, right: 16),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(
                    // left: 16,
                    // right: 16,
                    // bottom: 10,
                    // top: 10,
                  ),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: widget.emailController,
                        validator: emaildValidator.call,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          hintText: "Username",
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding * 0.98,
                            ),
                            child: SvgPicture.asset(
                              "assets/icons/User.svg",
                              height: 20,
                              width: 20,
                              colorFilter: ColorFilter.mode(
                                Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color!.withOpacity(0.3),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      TextFormField(
                        controller: widget.passwordController,
                        validator: passwordValidator.call,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          hintText: "Password",
                          suffixIcon: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextButton(
                                onPressed: () {
                                  togglePassword();
                                },
                                child: Icon(
                                  _obscureText
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Color.fromARGB(255, 131, 131, 131),
                                ),
                              ),
                            ],
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: defaultPadding * 0.75,
                            ),
                            child: SvgPicture.asset(
                              "assets/icons/Lock.svg",
                              height: 24,
                              width: 24,
                              colorFilter: ColorFilter.mode(
                                Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.color!.withOpacity(0.3),
                                BlendMode.srcIn,
                              ),
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
        ],
      ),
    );
  }
}
