import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protopos/assets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavlistMenu extends StatefulWidget {
  const NavlistMenu({super.key});

  @override
  State<NavlistMenu> createState() => _NavlistMenuState();
}

class _NavlistMenuState extends State<NavlistMenu> {
  bool _isLoading = false;

  _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: darkGreyColor,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: darkGreyColor),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No', style: TextStyle(color: whileColor60)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  _performLogout() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
      await Future.delayed(const Duration(seconds: 1)); // simulasi delay
      await prefsAuth.remove('keylogin');
      await prefsAuth.remove('userdata');

      // direct after logout
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint("Logout failed: $e");
      Get.snackbar('Error', 'Logout failed, please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          Ink(
            child: InkWell(
              // borderRadius: BorderRadius.circular(20),
              onTap: _showLogoutConfirmationDialog,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_outlined, color: errorColor, size: 20),
                    SizedBox(height: 1),
                    Text(
                      'Logout',
                      style: TextStyle(color: errorColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

        SizedBox(width: 16),

        // Ink(
        //   child: InkWell(
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         PageTransition(
        //           type: PageTransitionType.rightToLeft,
        //           alignment: Alignment.topCenter,
        //           // child: cartPage(),
        //         ),
        //       );
        //     },
        //     // child: Obx(),
        //   ),
        // ),
        // SizedBox(width: 20),
      ],
    );
  }
}
