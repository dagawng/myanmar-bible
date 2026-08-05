import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/get_verses.dart';
import 'bible_event.dart';
import 'bible_state.dart';

class BibleBloc extends Bloc<BibleEvent, BibleState> {
  final GetBooks getBooks;
  final GetVerses getVerses;

  BibleBloc({
    required this.getBooks,
    required this.getVerses,
  }) : super(BibleInitial()) {
    on<LoadBooksEvent>(_onLoadBooks);
    on<FilterTestamentEvent>(_onFilterTestament);
    on<SearchBooksEvent>(_onSearchBooks);
    on<SelectBookEvent>(_onSelectBook);
    on<LoadVersesEvent>(_onLoadVerses);
  }

  Future<void> _onLoadBooks(
    LoadBooksEvent event,
    Emitter<BibleState> emit,
  ) async {
    emit(BibleLoading());
    final result = await getBooks(event.languageId);
    result.fold(
      (failure) => emit(BibleError(failure.message)),
      (books) => emit(BooksLoaded(books: books)),
    );
  }

  void _onFilterTestament(
    FilterTestamentEvent event,
    Emitter<BibleState> emit,
  ) {
    if (state is BooksLoaded) {
      final currentState = state as BooksLoaded;
      emit(currentState.copyWith(
        selectedTestament: event.testament,
        clearTestament: event.testament == null,
      ));
    }
  }

  void _onSearchBooks(
    SearchBooksEvent event,
    Emitter<BibleState> emit,
  ) {
    if (state is BooksLoaded) {
      final currentState = state as BooksLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  void _onSelectBook(
    SelectBookEvent event,
    Emitter<BibleState> emit,
  ) {
    if (state is BooksLoaded) {
      final currentState = state as BooksLoaded;
      emit(currentState.copyWith(selectedBook: event.book));
    }
  }

  Future<void> _onLoadVerses(
    LoadVersesEvent event,
    Emitter<BibleState> emit,
  ) async {
    print('DEBUG: _onLoadVerses CALLED for book: ${event.book.id}, chapter: ${event.chapterNumber}');
    // Skip if already loaded for this exact book+chapter
    if (state is VersesLoaded) {
      final currentLoaded = state as VersesLoaded;
      if (currentLoaded.book?.id == event.book.id &&
          currentLoaded.chapterNumber == event.chapterNumber &&
          currentLoaded.verses.isNotEmpty) {
        print('DEBUG: Verses already loaded. Skipping.');
        return;
      }
    }

    print('DEBUG: Emitting BibleLoading...');
    emit(BibleLoading());
    try {
      print('DEBUG: Calling getVerses usecase...');
      final result = await getVerses(GetVersesParams(
        languageId: event.languageId,
        bookId: event.book.id,
        chapterNumber: event.chapterNumber,
      ));

      print('DEBUG: getVerses usecase returned.');
      result.fold(
        (failure) {
          print('DEBUG: Emitting BibleError: ${failure.message}');
          emit(BibleError(failure.message));
        },
        (verses) {
          print('DEBUG: Emitting VersesLoaded with ${verses.length} verses.');
          emit(VersesLoaded(
            book: event.book,
            chapterNumber: event.chapterNumber,
            verses: verses,
          ));
        },
      );
    } catch (e, stack) {
      print('DEBUG: Exception in _onLoadVerses: $e\n$stack');
      emit(BibleError('Failed to load verses: $e'));
    }
  }
}
