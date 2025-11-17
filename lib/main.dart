import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:protopos/assets.dart';
import 'package:protopos/const.dart';

import 'package:protopos/controller/webview/viewcontrol.dart';

import 'package:protopos/screen/auth/login.dart';
import 'package:protopos/screen/homepage/home.dart';
// import 'package:protopos/screen/layouts/mainapp.dart';
import 'package:protopos/screen/layouts/navigation.dart';
import 'package:protopos/screen/reports/index.dart';
import 'package:protopos/screen/settings/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:icons_plus/icons_plus.dart';

import 'package:protopos/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  runApp(const MyApp());
}

final _secondUrl = secondUrl;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return GetMaterialApp(
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,

      home: SplashScreen(),
      // home: SettingsPage(),

      // home: AuthLogin(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/home': (context) => const MyHomePage(),
        '/login': (context) => const LoginScreen(),
        '/settings': (context) => SettingsPage(),
        '/reports': (context) => ReportsView(url: thirddUrl),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: redirectPage(),
      builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.data != null && snapshot.data!) {
            return const MyHomePage();
          } else {
            // return const MyHomePage();
            return const LoginScreen();
          }
        }
      },
    );
  }

  Future<bool?> redirectPage() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    final String? magicKey = prefsAuth.getString('keylogin');
    // await prefsAuth.remove('magicKey');
    if (magicKey != null) {
      return true;
    } else {
      print('magicKey == ${magicKey}');
      return false;
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  final int initialIndex;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  bool _isPagesInitialized = false;
  final MainController mainController = Get.put(MainController());

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isPagesInitialized) {
      final url =
          ModalRoute.of(context)?.settings.arguments as String? ??
          // 'https://cms.myhaldin.com';
          _secondUrl;
      _pages = [
        HomeView(url: url),
        ReportsView(url: thirddUrl),
        SettingsPage(),
      ];
      _isPagesInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo_400.png',
              fit: BoxFit.contain,
              height: 45,
              alignment: Alignment.topLeft,
            ),
            const SizedBox(width: 10),
          ],
        ),
        actions: [NavlistMenu()],
        toolbarHeight: 70,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        // unselectedLabelStyle: mainStyle.defaultFont,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (int index) {
          if (index == _currentIndex) {
            if (index == 0) {
              mainController.webViewController?.reload();
            }
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_hashtag, size: 25),
            label: 'Home',
            activeIcon: Icon(Iconsax.home_hashtag, size: 30),
            // backgroundColor: Color(0xffcacaca),
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.receipt_2_1, size: 25),
            // icon: FaIcon(FontAwesomeIcons.help),
            label: 'Reports',
            activeIcon: Icon(Iconsax.receipt_2_1, size: 30),
            // backgroundColor: Color(0xff232323),
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.setting, size: 25),
            label: 'Settings',
            activeIcon: Icon(Iconsax.setting, size: 30),
          ),
        ],
      ),
    );
  }
}
