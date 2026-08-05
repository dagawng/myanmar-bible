import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/language_repository.dart';

class SetActiveLanguage {
  final LanguageRepository repository;
  const SetActiveLanguage(this.repository);

  Future<Either<Failure, void>> call(String languageId) {
    return repository.setActiveLanguage(languageId);
  }
}
