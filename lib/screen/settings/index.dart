import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protopos/assets.dart';
import 'package:protopos/screen/settings/print/index.dart';
import 'package:protopos/controller/webview/viewcontrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  String getProfileName = '';
  var urlProfilePic = '';
  final MainController mainController = Get.find();
  bool _isLoading = false;

  _loadDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? userData = prefs.getStringList('userdata');
    setState(() {
      getProfileName = '${userData?[0]}';
      urlProfilePic = '${userData?[1]}';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDataUser();
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
            child: ListView(
              children: [
                const Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: darkGreyColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: urlProfilePic.isNotEmpty
                        ? NetworkImage(urlProfilePic)
                        : const AssetImage('assets/icons/user.png')
                              as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome,',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: darkGreyColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  getProfileName.isNotEmpty ? getProfileName : 'User',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: darkGreyColor,
                  ),
                ),
                SizedBox(height: 22),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.to(() => const PrintPage());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Printer Setting',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: darkGreyColor,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_right, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: OutlinedButton(
                    onPressed: _performLogout,
                    // style: OutlinedButton.styleFrom(
                    //   side: const BorderSide(color: errorColor),
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 40,
                    //     vertical: 12,
                    //   ),
                    // ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2.2,

                        color: errorColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),

        // Overlay loading
        if (_isLoading)
          Container(
            color: darkGreyColor.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Logging out...",
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Row buildNotificationOptionRow(String title, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(value: isActive, onChanged: (bool val) {}),
        ),
      ],
    );
  }

  GestureDetector buildAccountOptionRow(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: const Column(mainAxisSize: MainAxisSize.min),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
