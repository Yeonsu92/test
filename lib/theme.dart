import "package:flutter/material.dart";

class Themedata {
  static ThemeData light() {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.white,
        iconTheme: IconThemeData(color: Color(0xff666666)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Color(0xff666666),
      ),
    );
  }
}
