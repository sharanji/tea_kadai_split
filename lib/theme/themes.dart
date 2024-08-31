// import 'package:email_bloc/logic/bloc/theme/theme_bloc.dart';
// import 'package:email_bloc/utils.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'package:flutter/material.dart';

class MyTheme {
  final String selectedFont;

  MyTheme(this.selectedFont);

  final Color primaryColor = Color.fromARGB(255, 255, 10, 10);
  final Color subPrimaryColor = Color.fromARGB(255, 255, 10, 10);
  final Color lightAppBarColor = Color.fromARGB(255, 255, 114, 114);
  final Color darkAppBarColor = Color(0xFF121212);
  final Color appBarTextColor = Colors.white;

  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: HexColor('#0B141B'),
        fontFamily: selectedFont,
        primaryColor: primaryColor,
        canvasColor: subPrimaryColor,
        // secondaryHeaderColor: Color.fromARGB(66, 32, 30, 30),
        colorScheme: ColorScheme.dark(primary: primaryColor),
        iconTheme: IconThemeData(color: primaryColor),
        // textTheme: const TextTheme().apply(
        //   bodyColor: Colors.pink,
        //   displayColor: Colors.pink,
        // ),
        appBarTheme: AppBarTheme(
          color: darkAppBarColor,
          iconTheme: IconThemeData(color: appBarTextColor),
          titleTextStyle: TextStyle(
            color: appBarTextColor,
            fontFamily: selectedFont,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          toolbarTextStyle: TextStyle(
            color: appBarTextColor,
            fontFamily: selectedFont,
            fontSize: 18.0,
          ),
        ),
      );

  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        secondaryHeaderColor: Color.fromARGB(255, 20, 20, 20),
        fontFamily: selectedFont,
        primaryColor: primaryColor,
        primaryColorLight: HexColor('#D6ECFF'),
        splashColor: Colors.grey,
        canvasColor: subPrimaryColor,
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.grey[500]),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: primaryColor, // Cursor color
           // Selection color
          selectionHandleColor: primaryColor, // Handle color
        ),
        iconTheme: const IconThemeData(color: Colors.blue),
        appBarTheme: AppBarTheme(
          toolbarHeight: 40,
          color: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: selectedFont,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
          toolbarTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: selectedFont,
            fontSize: 18.0,
          ),
        ),
      );
}

bool isUpdateTokenApiCalled = false;

Color primaryColor = HexColor('#FD293A');
const Color secondaryColor = Color(0xFF51DF4E);
const Color textPrimaryColor = Color.fromRGBO(2, 42, 81, 1);
const Color subPrimaryColor = Color.fromARGB(255, 218, 222, 222);
const Color subPrimaryColorDark = Color.fromARGB(255, 191, 196, 196);
const String isFirstTimeOpeningAppKey = "isFirstTimeOpeningApp";
const composeScreenColor = Color.fromARGB(255, 237, 236, 236);
const composeScreenSecondaryColor = Color(0xFF808080);
const Color primaryColorLight = Colors.white;
const Color secondaryColorLight = Colors.lightBlue;
const Color primaryColorDark = Colors.black;
const Color secondaryColorDark = Colors.lightBlue;
const Color settingtitleColor = Color.fromARGB(255, 207, 200, 243);

final G_REGEX_PATTERNS = {
  "mobile": RegExp(r'^[6-9]\d{9}$'),
  "email": RegExp(
      r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'),
  // "name": RegExp(r'^[a-zA-Z.]+( [a-zA-Z.]+)*$'),
  "name": RegExp(r"^[a-zA-Z.][a-zA-Z. ]*$"),
  "url": RegExp(
    r'^(https?://)?([A-Za-z0-9\-\.]+)\.([A-Za-z]{2,})(:[0-9]+)?(/.*)?$',
  )
};

const CardGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromRGBO(16, 117, 213, 100),
    Color.fromRGBO(41, 170, 41, 100),
  ],
);
