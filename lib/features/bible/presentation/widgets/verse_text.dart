import 'package:flutter/material.dart';
import '../../../../core/utils/script_utils.dart';
import '../../domain/entities/verse.dart';

class VerseText extends StatelessWidget {
  final Verse verse;
  final String script;
  final String fontFamily;
  final double fontSize;
  final bool isHighlighted;
  final Color? highlightColor;
  final VoidCallback? onTap;

  const VerseText({
    super.key,
    required this.verse,
    required this.script,
    required this.fontFamily,
    this.fontSize = 18.0,
    this.isHighlighted = false,
    this.highlightColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: isHighlighted
            ? (highlightColor ?? colorScheme.primaryContainer.withOpacity(0.4))
            : Colors.transparent,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${verse.verseNumber} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize * 0.8,
                  color: colorScheme.primary,
                ),
              ),
              TextSpan(
                text: verse.text,
                style: ScriptUtils.getTextStyle(
                  script: script,
                  fontFamily: fontFamily,
                  fontSize: fontSize,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
