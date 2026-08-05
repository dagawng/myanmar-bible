import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/language.dart';
import '../repositories/language_repository.dart';

class GetActiveLanguage {
  final LanguageRepository repository;
  const GetActiveLanguage(this.repository);

  Future<Either<Failure, Language>> call() {
    return repository.getActiveLanguage();
  }
}
