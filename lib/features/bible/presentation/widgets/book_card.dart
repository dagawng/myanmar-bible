import 'package:flutter/material.dart';
import '../../../../core/constants/bible_constants.dart';
import '../../../../core/utils/script_utils.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final String script;
  final String fontFamily;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.script,
    required this.fontFamily,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOldTestament = book.testament == BibleTestament.old;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Order / Abbreviation Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOldTestament
                        ? colorScheme.primaryContainer
                        : colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      book.order.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isOldTestament
                            ? colorScheme.primary
                            : colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Book Title & En Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.name,
                        style: ScriptUtils.getTextStyle(
                          script: script,
                          fontFamily: fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${book.nameEn} • ${book.totalChapters} Chapters',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron Indicator
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
