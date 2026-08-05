import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/language.dart';

abstract class LanguageRepository {
  Future<Either<Failure, List<Language>>> getLanguages();
  Future<Either<Failure, Language>> getActiveLanguage();
  Future<Either<Failure, void>> setActiveLanguage(String languageId);
}
