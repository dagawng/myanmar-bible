import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../language/presentation/bloc/language_cubit.dart';
import '../../../language/presentation/bloc/language_state.dart';
import '../bloc/bible_bloc.dart';
import '../bloc/bible_event.dart';
import '../../domain/entities/book.dart';
import '../widgets/chapter_grid.dart';
import 'verse_reader_page.dart';

import '../../../../core/presentation/pages/main_navigation_page.dart';
import '../../../../core/di/injection.dart';

class ChapterListPage extends StatelessWidget {
  final Book book;
  final String script;
  final String fontFamily;

  const ChapterListPage({
    super.key,
    required this.book,
    required this.script,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
              );
            }
          },
        ),
        title: Text(
          '${book.name} (${book.nameEn})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Select Chapter (Total ${book.totalChapters})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: ChapterGrid(
              totalChapters: book.totalChapters,
              onChapterSelected: (chapterNum) {
                final languageState = context.read<LanguageCubit>().state;
                if (languageState is LanguagesLoaded) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<BibleBloc>(),
                        child: VerseReaderPage(
                          book: book,
                          chapterNumber: chapterNum,
                          script: script,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
