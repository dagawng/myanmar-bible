import '../../domain/entities/audio_track.dart';

class AudioTrackModel extends AudioTrack {
  const AudioTrackModel({
    required super.id,
    required super.languageId,
    required super.bookId,
    required super.bookName,
    required super.chapterNumber,
    required super.audioUrl,
    required super.duration,
  });

  factory AudioTrackModel.fromJson(Map<String, dynamic> json) {
    return AudioTrackModel(
      id: json['id'] as String,
      languageId: json['language_id'] as String,
      bookId: json['book_id'] as String,
      bookName: json['book_name'] as String,
      chapterNumber: json['chapter'] as int,
      audioUrl: json['audio_url'] as String,
      duration: Duration(milliseconds: json['duration_ms'] as int? ?? 180000),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'language_id': languageId,
        'book_id': bookId,
        'book_name': bookName,
        'chapter': chapterNumber,
        'audio_url': audioUrl,
        'duration_ms': duration.inMilliseconds,
      };
}
