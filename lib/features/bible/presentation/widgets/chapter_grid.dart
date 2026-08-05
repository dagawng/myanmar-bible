import 'package:flutter/material.dart';

class ChapterGrid extends StatelessWidget {
  final int totalChapters;
  final ValueChanged<int> onChapterSelected;

  const ChapterGrid({
    super.key,
    required this.totalChapters,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: totalChapters,
      itemBuilder: (context, index) {
        final chapterNumber = index + 1;
        return Material(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onChapterSelected(chapterNumber),
            child: Center(
              child: Text(
                chapterNumber.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
