import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/verse.dart';
import '../repositories/bible_repository.dart';

class GetVersesParams {
  final String languageId;
  final String bookId;
  final int chapterNumber;

  const GetVersesParams({
    required this.languageId,
    required this.bookId,
    required this.chapterNumber,
  });
}

class GetVerses {
  final BibleRepository repository;
  const GetVerses(this.repository);

  Future<Either<Failure, List<Verse>>> call(GetVersesParams params) {
    return repository.getVerses(
      languageId: params.languageId,
      bookId: params.bookId,
      chapterNumber: params.chapterNumber,
    );
  }
}
