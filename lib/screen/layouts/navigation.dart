import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:page_transition/page_transition.dart';

class NavlistMenu extends StatelessWidget {
  const NavlistMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final CartController cartController = Get.find();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Ink(
        //   child: InkWell(
        //     borderRadius: BorderRadius.circular(20),
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         PageTransition(
        //           type: PageTransitionType.rightToLeft,
        //           alignment: Alignment.topCenter,
        //           // child: SearchPage(
        //           //   // xcatID: 136,
        //           // ),
        //         ),
        //       );
        //     },
        //     child: Icon(Bootstrap.search, color: Color(0xFF606060), size: 20),
        //   ),
        // ),
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
