import 'package:flutter/material.dart';
import 'package:protopos/screen/reports/components/webview.dart';

// ignore: camel_case_types
class ReportsView extends StatelessWidget {
  final String url;
  const ReportsView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // return WebViewScreen(url: url);
    return PopScope(canPop: false, child: WebViewScreen(url: url));
  }
}
