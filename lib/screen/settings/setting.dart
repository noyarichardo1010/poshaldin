import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:poshaldin/controller/main_controller.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  String urlProfilePic = '';
  var getProfileName = '';
  final MainController mainController = Get.find();

  bool _isLoading = false;

  loadDataLogin() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();

    setState(() {});
    print('Test Print Data ${getProfileName}');
  }

  _performLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final SharedPreferences prefsAuth = await SharedPreferences.getInstance();

      await prefsAuth.remove('tokenlogin');

      Get.offAllNamed('/login');
    } catch (e) {
      print("Logout failed: $e");

      Get.snackbar('Error', 'Logout failed, please try again.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadDataLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                color: Color(0xff232323),
              ),
            ),
            SizedBox(height: 16),
            Container(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 35,
                backgroundImage: urlProfilePic.isNotEmpty
                    ? NetworkImage(urlProfilePic)
                    : AssetImage('assets/images/user.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome,',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff232323),
              ),
            ),
            SizedBox(height: 5),
            Text(
              getProfileName.isNotEmpty ? getProfileName : 'User',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff232323),
              ),
            ),
            SizedBox(height: 50),
            SizedBox(height: 10),
            SizedBox(height: 50),
            Center(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _performLogout,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color.fromARGB(255, 218, 1, 1),
                        ),
                      )
                    : Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 2.2,
                          color: const Color.fromARGB(255, 218, 1, 1),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(height: 16),
          ],
        ),
      ),
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
              content: Column(mainAxisSize: MainAxisSize.min),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close"),
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
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
