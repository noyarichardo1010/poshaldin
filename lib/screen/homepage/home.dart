import 'package:flutter/material.dart';
import 'package:poshaldin/screen/homepage/components/webview.dart';

class homeView extends StatelessWidget {
  final String url;
  const homeView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return WebViewScreen(url: url);
  }
}
