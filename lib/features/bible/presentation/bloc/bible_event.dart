import 'package:equatable/equatable.dart';
import '../../../../core/constants/bible_constants.dart';
import '../../domain/entities/book.dart';

abstract class BibleEvent extends Equatable {
  const BibleEvent();

  @override
  List<Object?> get props => [];
}

class LoadBooksEvent extends BibleEvent {
  final String languageId;

  const LoadBooksEvent({required this.languageId});

  @override
  List<Object?> get props => [languageId];
}

class FilterTestamentEvent extends BibleEvent {
  final BibleTestament? testament;

  const FilterTestamentEvent(this.testament);

  @override
  List<Object?> get props => [testament];
}

class SearchBooksEvent extends BibleEvent {
  final String query;

  const SearchBooksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectBookEvent extends BibleEvent {
  final Book book;

  const SelectBookEvent(this.book);

  @override
  List<Object?> get props => [book];
}

class LoadVersesEvent extends BibleEvent {
  final String languageId;
  final Book book;
  final int chapterNumber;

  const LoadVersesEvent({
    required this.languageId,
    required this.book,
    required this.chapterNumber,
  });

  @override
  List<Object?> get props => [languageId, book.id, chapterNumber];
}
