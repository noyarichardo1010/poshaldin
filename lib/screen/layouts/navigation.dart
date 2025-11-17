// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:icons_plus/icons_plus.dart';
// import 'package:page_transition/page_transition.dart';
import 'package:protopos/assets.dart';

class NavlistMenu extends StatelessWidget {
  const NavlistMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Ink(
          child: InkWell(
            // borderRadius: BorderRadius.circular(20),
            onTap: () {},
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
