import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/bible_constants.dart';
import '../../../language/presentation/bloc/language_cubit.dart';
import '../../../language/presentation/bloc/language_state.dart';
import '../../../language/presentation/pages/language_picker_page.dart';
import '../bloc/bible_bloc.dart';
import '../bloc/bible_event.dart';
import '../bloc/bible_state.dart';
import '../widgets/book_card.dart';
import 'chapter_list_page.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  @override
  void initState() {
    super.initState();
    _loadBooksForActiveLanguage();
  }

  void _loadBooksForActiveLanguage() {
    final languageState = context.read<LanguageCubit>().state;
    if (languageState is LanguagesLoaded) {
      context.read<BibleBloc>().add(
            LoadBooksEvent(languageId: languageState.activeLanguage.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<LanguageCubit, LanguageState>(
      listener: (context, state) {
        if (state is LanguagesLoaded) {
          context.read<BibleBloc>().add(
                LoadBooksEvent(languageId: state.activeLanguage.id),
              );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<LanguageCubit, LanguageState>(
            builder: (context, state) {
              final title = state is LanguagesLoaded
                  ? state.activeLanguage.name
                  : 'Bible Books';
              return Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.language_rounded),
              tooltip: 'Switch Bible Language',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LanguagePickerPage(),
                  ),
                );
              },
            ),
          ],
          centerTitle: true,
        ),
        body: BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, languageState) {
            final script = languageState is LanguagesLoaded
                ? languageState.activeLanguage.script
                : 'myanmar';
            final fontFamily = languageState is LanguagesLoaded
                ? languageState.activeLanguage.fontFamily
                : 'Padauk';

            return BlocBuilder<BibleBloc, BibleState>(
              builder: (context, state) {
                if (state is BibleInitial || state is BibleLoading) {
                  // If books haven't loaded yet, try loading if languages loaded
                  if (state is BibleInitial && languageState is LanguagesLoaded) {
                    context.read<BibleBloc>().add(
                          LoadBooksEvent(
                              languageId: languageState.activeLanguage.id),
                        );
                  }
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is BibleError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            if (languageState is LanguagesLoaded) {
                              context.read<BibleBloc>().add(
                                    LoadBooksEvent(
                                        languageId:
                                            languageState.activeLanguage.id),
                                  );
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is BooksLoaded) {
                  final filtered = state.filteredBooks;

                  return Column(
                    children: [
                      // Search Bar removed per user request

                      // Testament Segmented Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 6.0),
                        child: SegmentedButton<BibleTestament?>(
                          segments: const [
                            ButtonSegment<BibleTestament?>(
                              value: null,
                              label: Text('All'),
                              icon: Icon(Icons.menu_book_rounded),
                            ),
                            ButtonSegment<BibleTestament?>(
                              value: BibleTestament.old,
                              label: Text('Old'),
                            ),
                            ButtonSegment<BibleTestament?>(
                              value: BibleTestament.newTestament,
                              label: Text('New'),
                            ),
                          ],
                          selected: {state.selectedTestament},
                          onSelectionChanged: (newSelection) {
                            context.read<BibleBloc>().add(
                                  FilterTestamentEvent(newSelection.first),
                                );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Book List
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No books found'))
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final book = filtered[index];
                                  return BookCard(
                                    book: book,
                                    script: script,
                                    fontFamily: fontFamily,
                                    onTap: () {
                                      context
                                          .read<BibleBloc>()
                                          .add(SelectBookEvent(book));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChapterListPage(
                                            book: book,
                                            script: script,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
