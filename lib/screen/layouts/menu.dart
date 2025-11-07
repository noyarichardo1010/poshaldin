// import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class menuP extends StatefulWidget {
//   const menuP({super.key});

//   @override
//   State<menuP> createState() => _menuPState();
// }

// logout() async {
//   final SharedPreferences prefsAuth = await SharedPreferences.getInstance();
//   await prefsAuth.remove('tokenKey2');
//   await prefsAuth.remove('cart2');
// }

// class _menuPState extends State<menuP> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Container(
//             margin: EdgeInsets.only(bottom: 5, top: 5, left: 16, right: 16),
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               border: Border.all(width: 1, color: Color(0xffE8E8E8)),
//             ),
//             child: TextButton.icon(
//               style: TextButton.styleFrom(),
//               onPressed: () {},
//               icon: Icon(FontAwesome.user, size: 22),
//               label: Row(
//                 children: [
//                   Column(
//                     children: [
//                       Container(
//                         margin: EdgeInsets.only(left: 5),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Profile', textAlign: TextAlign.start),
//                             Text(
//                               'Informasi About your Profile',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xff8E8E8E),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [Icon(FontAwesome.chevron_right, size: 16)],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(bottom: 5, top: 5, left: 16, right: 16),
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               border: Border.all(width: 1, color: Color(0xffE8E8E8)),
//             ),
//             child: TextButton.icon(
//               style: TextButton.styleFrom(),
//               onPressed: () {},
//               icon: Icon(FontAwesome.map, size: 22),
//               label: Row(
//                 children: [
//                   Column(
//                     children: [
//                       Container(
//                         // alignment: Alignment.centerLeft,
//                         margin: EdgeInsets.only(left: 5),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Address', textAlign: TextAlign.start),
//                             Text(
//                               'Your Address',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xff8E8E8E),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [Icon(FontAwesome.chevron_right, size: 16)],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(bottom: 5, top: 5, left: 16, right: 16),
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               border: Border.all(width: 1, color: Color(0xffE8E8E8)),
//             ),
//             child: TextButton.icon(
//               style: TextButton.styleFrom(),
//               onPressed: () {},
//               icon: Icon(FontAwesome.lock, size: 22),
//               label: Row(
//                 children: [
//                   Column(
//                     children: [
//                       Container(
//                         // alignment: Alignment.centerLeft,
//                         margin: EdgeInsets.only(left: 5),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Change password ',
//                               textAlign: TextAlign.start,
//                             ),
//                             Text(
//                               'Change your password',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xff8E8E8E),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [Icon(FontAwesome.chevron_right, size: 16)],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container(
//             margin: EdgeInsets.only(bottom: 5, top: 16, left: 16, right: 16),
//             width: MediaQuery.of(context).size.width,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               border: Border.all(width: 1, color: Color(0xffE8E8E8)),
//             ),
//             child: TextButton.icon(
//               style: TextButton.styleFrom(),
//               onPressed: () {
//                 showDialog<void>(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Text(
//                         'Signout from application?',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       content: const Text(
//                         'You must login to access the application',
//                       ),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () {
//                             Navigator.of(context).pop();
//                           },
//                           child: Text(
//                             'No',
//                             style: TextStyle(
//                               color: Color(0xff232323),
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         TextButton(
//                           onPressed: () async {
//                             setState(() {});
//                             logout();
//                             Navigator.pushNamed(context, '/login');
//                           },
//                           child: Text(
//                             'Yes, Signout!',
//                             style: TextStyle(
//                               color: Color(0xff29B706),
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//               icon: Icon(FontAwesome.right_from_bracket, size: 16),
//               label: Text(
//                 'Logout',
//                 style: TextStyle(fontSize: 16, color: Color(0xff232323)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
