import 'package:flutter/material.dart';
import 'package:protopos/screen/homepage/components/webview.dart';

// ignore: camel_case_types
class HomeView extends StatelessWidget {
  final String url;
  const HomeView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: WebViewScreen(url: url));
  }
}
