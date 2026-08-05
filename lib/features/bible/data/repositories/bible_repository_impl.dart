import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../datasources/bible_local_datasource.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../models/chapter_model.dart';

/// Bible data is stored locally in asset files.
/// No network or Firebase needed for reading Bible text.
class BibleRepositoryImpl implements BibleRepository {
  final BibleLocalDatasource localDatasource;

  BibleRepositoryImpl({required this.localDatasource});

  @override
  Future<Either<Failure, List<Book>>> getBooks({required String languageId}) async {
    final books = await localDatasource.getPreSeededBooks(languageId);
    return Right(books);
  }

  @override
  Future<Either<Failure, List<Verse>>> getVerses({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  }) async {
    final verses = await localDatasource.getPreSeededVerses(
      languageId: languageId,
      bookId: bookId,
      chapterNumber: chapterNumber,
    );
    return Right(verses);
  }

  @override
  Future<Either<Failure, Chapter>> getChapter({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  }) async {
    final versesResult = await getVerses(
      languageId: languageId,
      bookId: bookId,
      chapterNumber: chapterNumber,
    );

    return versesResult.fold(
      (failure) => Left(failure),
      (verses) {
        final chapter = ChapterModel(
          chapterNumber: chapterNumber,
          audioPath:
              'audio/$languageId/$bookId/chapter_${chapterNumber.toString().padLeft(2, '0')}.mp3',
          audioDurationMs: 180000,
          verses: verses,
        );
        return Right(chapter);
      },
    );
  }
}
