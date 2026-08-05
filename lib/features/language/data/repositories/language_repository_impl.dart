import 'package:dartz/dartz.dart';
import '../../../../core/constants/bible_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/language_local_datasource.dart';
import '../datasources/language_remote_datasource.dart';
import '../../domain/entities/language.dart';
import '../../domain/repositories/language_repository.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageRemoteDatasource remoteDatasource;
  final LanguageLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  LanguageRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Language>>> getLanguages() async {
    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      try {
        final remoteLanguages = await remoteDatasource.getLanguages();
        if (remoteLanguages.isNotEmpty) {
          return Right(remoteLanguages);
        }
      } catch (_) {
        // Fallback to local offline languages if Firestore query fails/unseeded
      }
    }
    // Return pre-seeded offline languages
    final localLanguages = await localDatasource.getPreSeededLanguages();
    return Right(localLanguages);
  }

  @override
  Future<Either<Failure, Language>> getActiveLanguage() async {
    try {
      final activeId = await localDatasource.getActiveLanguageId() ??
          BibleConstants.defaultLanguageId;

      final languagesResult = await getLanguages();
      return languagesResult.fold(
        (failure) => Left(failure),
        (languages) {
          final activeLanguage = languages.firstWhere(
            (lang) => lang.id == activeId,
            orElse: () => languages.first,
          );
          return Right(activeLanguage);
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setActiveLanguage(String languageId) async {
    try {
      await localDatasource.setActiveLanguageId(languageId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
