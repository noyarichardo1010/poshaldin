import 'package:flutter/material.dart';
import 'package:protopos/screen/homepage/components/webview.dart';

// ignore: camel_case_types
class homeView extends StatelessWidget {
  final String url;
  const homeView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return WebViewScreen(url: url);
  }
}
