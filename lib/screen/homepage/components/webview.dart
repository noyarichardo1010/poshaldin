import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:poshaldin/controller/main_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  const WebViewScreen({super.key, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  final MainController mainController = Get.find();

  @override
  void initState() {
    super.initState();

    if (WebViewPlatform.instance == null &&
        WebViewPlatform is AndroidWebViewPlatform) {
      // WebView.platform = SurfaceAndroidWebView();
    }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'ExitBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _logout();
        },
      )
      ..loadRequest(Uri.parse(widget.url));
    mainController.webViewController = controller;
  }

  void _logout() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    await prefsAuth.remove('tokenKey2');
    await prefsAuth.remove('cart2');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.reload();
        },
        child: SafeArea(child: WebViewWidget(controller: controller)),
      ),
    );
  }
}
