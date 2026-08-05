import 'package:flutter/material.dart';

class ScriptUtils {
  /// Returns line height according to script requirements.
  /// Myanmar script needs generous spacing (1.8), Latin standard (1.5).
  static double getLineHeight(String script) {
    switch (script.toLowerCase()) {
      case 'myanmar':
        return 1.8;
      case 'shan':
        return 1.7;
      case 'karen':
        return 1.7;
      case 'kayah_li':
        return 1.6;
      case 'latin':
      default:
        return 1.5;
    }
  }

  /// Returns letter spacing based on script type.
  static double getLetterSpacing(String script) {
    return script.toLowerCase() == 'latin' ? 0.0 : 0.3;
  }

  /// Builds a TextStyle configured for the language's script and dynamic font family.
  static TextStyle getTextStyle({
    required String script,
    required String fontFamily,
    double fontSize = 18.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: getLineHeight(script),
      letterSpacing: getLetterSpacing(script),
      color: color,
    );
  }

  /// Converts an integer or string number to local numeral strings based on languageId.
  static String localizeNumber(dynamic number, String languageId) {
    final numberStr = number.toString();
    if (languageId == 'my_burmese') {
      final myanmarDigits = ['၀', '၁', '၂', '၃', '၄', '၅', '၆', '၇', '၈', '၉'];
      return numberStr.split('').map((char) {
        final digit = int.tryParse(char);
        return digit != null ? myanmarDigits[digit] : char;
      }).join('');
    }
    return numberStr;
  }
}
