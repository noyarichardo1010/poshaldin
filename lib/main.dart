import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'package:poshaldin/screen/auth/login.dart';
import 'package:poshaldin/screen/homepage/home.dart';
import 'package:poshaldin/screen/layouts/mainapp.dart';
import 'package:poshaldin/screen/layouts/navigation.dart';
import 'package:poshaldin/screen/settings/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:icons_plus/icons_plus.dart';

import 'package:poshaldin/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    return GetMaterialApp(
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,

      home: SplashScreen(),

      // home: AuthLogin(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/home': (context) => const MyHomePage(),
        '/login': (context) => const LoginScreen(),
        '/settings': (context) => SettingsPage(),
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
            return const MyHomePage();

            // return const LoginScreen();
          }
        }
      },
    );
  }

  Future<bool?> redirectPage() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    final String? tokenKey = prefsAuth.getString('tokenKey2');
    // await prefsAuth.remove('tokenKey2');
    if (tokenKey != null) {
      return true;
    } else {
      print('TOKEN NULL');
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
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final url =
        ModalRoute.of(context)?.settings.arguments as String? ??
        // 'https://cms.myhaldin.com';
        'https:google.com';
    _pages = [homeView(url: url), SettingsPage(), SettingsPage()];

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
        selectedItemColor: mainStyle.colorBlue,
        unselectedItemColor: Colors.grey,
        // unselectedLabelStyle: mainStyle.defaultFont,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_hashtag, size: 25),
            label: 'Home',
            activeIcon: Icon(Iconsax.home_hashtag, size: 30),
            // backgroundColor: Color(0xffcacaca),
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.activity, size: 25),
            // icon: FaIcon(FontAwesomeIcons.help),
            label: 'Others',
            activeIcon: Icon(Iconsax.shopping_bag, size: 30),
            // backgroundColor: Color(0xff232323),
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.menu_1, size: 25),
            label: 'Settings',
            activeIcon: Icon(Iconsax.menu_1, size: 30),
          ),
        ],
      ),
    );
  }
}
