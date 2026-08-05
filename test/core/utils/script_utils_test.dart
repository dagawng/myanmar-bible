import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_bible_audio/core/utils/script_utils.dart';

void main() {
  group('ScriptUtils', () {
    test('should return 1.8 for myanmar script line height', () {
      final height = ScriptUtils.getLineHeight('myanmar');
      expect(height, equals(1.8));
    });

    test('should return 1.5 for latin script line height', () {
      final height = ScriptUtils.getLineHeight('latin');
      expect(height, equals(1.5));
    });

    test('should return 0.0 letter spacing for latin script', () {
      final spacing = ScriptUtils.getLetterSpacing('latin');
      expect(spacing, equals(0.0));
    });

    test('should return 0.3 letter spacing for myanmar script', () {
      final spacing = ScriptUtils.getLetterSpacing('myanmar');
      expect(spacing, equals(0.3));
    });
  });
}
