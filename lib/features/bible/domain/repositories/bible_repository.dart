import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../entities/chapter.dart';
import '../entities/verse.dart';

abstract class BibleRepository {
  Future<Either<Failure, List<Book>>> getBooks({required String languageId});
  Future<Either<Failure, Chapter>> getChapter({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  });
  Future<Either<Failure, List<Verse>>> getVerses({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  });
}
