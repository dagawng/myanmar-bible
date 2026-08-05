import 'package:equatable/equatable.dart';
import '../../../../core/constants/bible_constants.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/verse.dart';

abstract class BibleState extends Equatable {
  const BibleState();

  @override
  List<Object?> get props => [];
}

class BibleInitial extends BibleState {}

class BibleLoading extends BibleState {}

class BooksLoaded extends BibleState {
  final List<Book> books;
  final BibleTestament? selectedTestament;
  final String searchQuery;
  final Book? selectedBook;

  const BooksLoaded({
    required this.books,
    this.selectedTestament,
    this.searchQuery = '',
    this.selectedBook,
  });

  List<Book> get filteredBooks {
    return books.where((book) {
      final matchesTestament = selectedTestament == null || book.testament == selectedTestament;
      final matchesQuery = searchQuery.trim().isEmpty ||
          book.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          book.nameEn.toLowerCase().contains(searchQuery.toLowerCase()) ||
          book.abbreviation.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesTestament && matchesQuery;
    }).toList();
  }

  BooksLoaded copyWith({
    List<Book>? books,
    BibleTestament? selectedTestament,
    bool clearTestament = false,
    String? searchQuery,
    Book? selectedBook,
  }) {
    return BooksLoaded(
      books: books ?? this.books,
      selectedTestament: clearTestament ? null : (selectedTestament ?? this.selectedTestament),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBook: selectedBook ?? this.selectedBook,
    );
  }

  @override
  List<Object?> get props => [books, selectedTestament, searchQuery, selectedBook];
}

class VersesLoaded extends BibleState {
  final Book book;
  final int chapterNumber;
  final List<Verse> verses;

  const VersesLoaded({
    required this.book,
    required this.chapterNumber,
    required this.verses,
  });

  @override
  List<Object?> get props => [book, chapterNumber, verses];
}

class BibleError extends BibleState {
  final String message;

  const BibleError(this.message);

  @override
  List<Object?> get props => [message];
}
