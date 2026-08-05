import 'package:flutter/material.dart';
import '../../../../core/utils/script_utils.dart';
import '../../domain/entities/language.dart';

class LanguageTile extends StatelessWidget {
  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withOpacity(0.5),
            width: isSelected ? 2.0 : 1.0,
          ),
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.surface,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Language icon / script badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      language.languageCode.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Language Names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.name,
                        style: ScriptUtils.getTextStyle(
                          script: language.script,
                          fontFamily: language.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        language.nameEn,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Audio Available Badge & Selected Checkmark
                if (language.hasAudio) ...[
                  Icon(
                    Icons.volume_up_rounded,
                    size: 20,
                    color: colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                ],
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
