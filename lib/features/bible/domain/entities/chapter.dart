import 'package:equatable/equatable.dart';
import 'verse.dart';

class Chapter extends Equatable {
  final int chapterNumber;
  final String audioPath;
  final int audioDurationMs;
  final List<Verse> verses;

  const Chapter({
    required this.chapterNumber,
    required this.audioPath,
    required this.audioDurationMs,
    required this.verses,
  });

  @override
  List<Object?> get props => [
        chapterNumber,
        audioPath,
        audioDurationMs,
        verses,
      ];
}
