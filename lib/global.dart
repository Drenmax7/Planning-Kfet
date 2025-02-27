import 'package:flutter/material.dart';

class GlobalColor {
  static const Color tableHeader = Color(0xFFADD8E6);
  static const Color tableOddLine = Color(0xFFF5F5DC);
  static const Color tableEvenLine = Color(0xFFD5F5E3);
  static const Color tableOddLineOFF = Color(0xFF808080);
  static const Color tableEvenLineOFF = Color(0xFFB0B0B0);

  static const Color buttonRed = Color(0xFFFF4D4D);
  static const Color buttonGreen = Color(0xFF4CAF50);
  static const Color buttonOrange = Color(0xFFFF9800);
  static const Color buttonYellow = Color(0xFFFFD700);
  static const Color buttonPurple = Color(0xFF8A2BE2);

  static void afficheSnackBar(BuildContext context, String texte){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: texte.length.toDouble() * 10,
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Text(
          texte,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,

          ),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}