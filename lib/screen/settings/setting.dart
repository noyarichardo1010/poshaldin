import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPage createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  String urlProfilePic = '';
  var getProfileName = '';

  loadDataLogin() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    final List<String>? DataProfile = prefsAuth.getStringList('DataloginUser');
    final List<String>? AuthData = prefsAuth.getStringList('AuthData');
    // var currentItem = jsonDecode(TestPrintLoginData.toString());
    // customerPhone = DataProfile![9];
    // CustomerAddress = DataProfile[4];
    // print('DATA Alamat ${CustomerAddress}');
    // print('DATA BILING ${DataProfile}');
    print('Test Print Data ${DataProfile}}');
    print('AuthData from settings: $AuthData');
    // print('Test Print Data detail ${DataProfile![4]}');
    setState(() {
      // AuthData: [user_email, user_nicename, user_display_name]
      final String aEmail = (AuthData != null && AuthData.length > 0)
          ? (AuthData[0] ?? '')
          : '';
      final String aNice = (AuthData != null && AuthData.length > 1)
          ? (AuthData[1] ?? '')
          : '';
      final String aDisp = (AuthData != null && AuthData.length > 2)
          ? (AuthData[2] ?? '')
          : '';
      // DataloginUser: [id, avatar_url, email, firstName, lastName, role, username]
      final String wcUsername = (DataProfile != null && DataProfile.length > 6)
          ? (DataProfile[6] ?? '')
          : '';
      getProfileName = aDisp;
      // avatar_url is at index 1, guard for null/short list
      urlProfilePic = (DataProfile != null && DataProfile.length > 1)
          ? (DataProfile[1] ?? '')
          : '';
      // nameProfile_lastname.value =
      //     (TextEditingValue(text: '${DataProfile[4]}'));
      // userNameProfile.value = (TextEditingValue(text: '${DataProfile[6]}'));
      // emailProfile.value = (TextEditingValue(text: '${DataProfile[2]}'));
    });
    print('Test Print Data ${getProfileName}');

    // return DataProfile;
  }

  logout() async {
    final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
    await prefsAuth.remove('tokenKey2');
    // await prefsAuth.remove('cart2');
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
              // getProfileName[0],
              getProfileName.isNotEmpty ? getProfileName : 'User',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xff232323),
              ),
            ),
            SizedBox(height: 50),
            Container(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Get.to(AddressPage());
                      // Get.to(() => ProfilePageSetting());
                      // loadDataProvince();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Column(
                            children: [
                              Text(
                                'Profile',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff232323),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [Icon(FontAwesome.chevron_right, size: 16)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Get.to(AddressPage());
                      // Get.to(() => AddressPage());
                      // Get.to(() => AddressForm());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Column(
                            children: [
                              Text(
                                'Address Settings',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff232323),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [Icon(FontAwesome.chevron_right, size: 16)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Get.to(() => changePasswordPageSetting());
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Column(
                            children: [
                              Text(
                                'Change Password',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff232323),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Column(
                        children: [Icon(FontAwesome.chevron_right, size: 16)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 50),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  logout();

                  // Get.to(() => LoginScreen());
                },
                child: Text(
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
            // CopyrightWidget(),
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Option 1"),
                  Text("Option 2"),
                  Text("Option 3"),
                  Text("Option 4"),
                ],
              ),
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
