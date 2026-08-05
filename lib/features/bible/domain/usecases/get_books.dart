import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/bible_repository.dart';

class GetBooks {
  final BibleRepository repository;
  const GetBooks(this.repository);

  Future<Either<Failure, List<Book>>> call(String languageId) {
    return repository.getBooks(languageId: languageId);
  }
}
