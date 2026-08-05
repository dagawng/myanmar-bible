import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/audio_track.dart';
import '../repositories/audio_repository.dart';

class GetAudioTrack {
  final AudioRepository repository;

  const GetAudioTrack(this.repository);

  Future<Either<Failure, AudioTrack>> call(GetAudioTrackParams params) {
    return repository.getAudioTrack(
      languageId: params.languageId,
      bookId: params.bookId,
      bookName: params.bookName,
      chapterNumber: params.chapterNumber,
    );
  }
}

class GetAudioTrackParams extends Equatable {
  final String languageId;
  final String bookId;
  final String bookName;
  final int chapterNumber;

  const GetAudioTrackParams({
    required this.languageId,
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
  });

  @override
  List<Object?> get props => [languageId, bookId, bookName, chapterNumber];
}
