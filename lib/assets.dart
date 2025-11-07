import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Just for demo
const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
// End For demo

const grandisExtendedFont = "Grandis Extended";

const Color primaryColor = Color(0xFF007ECD);

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFF007ECD, <int, Color>{
      50: Color(0xFFE0F4FB),
      100: Color(0xFFB3E2F6),
      200: Color(0xFF80CFF0),
      300: Color(0xFF4DBBEA),
      400: Color(0xFF26ACE6),
      500: Color(0xFF009DDE),
      600: Color(0xFF008FCC),
      700: Color(0xFF007ECD),
      800: Color(0xFF006EB5),
      900: Color(0xFF005185),
    });

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);

const Color purpleColor = Color(0xFF007ecd);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(6, errorText: 'password must be at least 8 digits long'),
  // PatternValidator(r'(?=.*?[#?!@$%^&*-])',
  // errorText: 'passwords must have at least one special character')
]);

// final emaildValidator = MultiValidator([
//   RequiredValidator(errorText: 'Email is required'),
//   EmailValidator(errorText: "Enter a valid email address"),
// ]);

const pasNotMatchErrorText = "passwords do not match";
