import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audio_track.dart';

abstract class AudioRepository {
  Future<Either<Failure, AudioTrack>> getAudioTrack({
    required String languageId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  });
}
