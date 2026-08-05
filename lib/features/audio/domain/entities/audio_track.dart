import 'package:equatable/equatable.dart';

class AudioTrack extends Equatable {
  final String id;
  final String languageId;
  final String bookId;
  final String bookName;
  final int chapterNumber;
  final String audioUrl;
  final Duration duration;

  const AudioTrack({
    required this.id,
    required this.languageId,
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.audioUrl,
    required this.duration,
  });

  @override
  List<Object?> get props => [
        id,
        languageId,
        bookId,
        bookName,
        chapterNumber,
        audioUrl,
        duration,
      ];
}
