import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/language.dart';
import '../repositories/language_repository.dart';

class GetLanguages {
  final LanguageRepository repository;
  const GetLanguages(this.repository);

  Future<Either<Failure, List<Language>>> call() {
    return repository.getLanguages();
  }
}
