import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/audio_local_datasource.dart';
import '../datasources/audio_remote_datasource.dart';
import '../../domain/entities/audio_track.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDatasource remoteDatasource;
  final AudioLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  AudioRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AudioTrack>> getAudioTrack({
    required String languageId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      try {
        final remoteTrack = await remoteDatasource.getAudioTrack(
          languageId: languageId,
          bookId: bookId,
          bookName: bookName,
          chapterNumber: chapterNumber,
        );
        if (remoteTrack != null && remoteTrack.audioUrl.isNotEmpty) {
          return Right(remoteTrack);
        }
      } catch (_) {}
    }

    final localTrack = await localDatasource.getPreSeededAudioTrack(
      languageId: languageId,
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
    );
    return Right(localTrack);
  }
}
