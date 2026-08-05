import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chapter.dart';
import 'verse_model.dart';

class ChapterModel extends Chapter {
  const ChapterModel({
    required super.chapterNumber,
    required super.audioPath,
    required super.audioDurationMs,
    required super.verses,
  });

  factory ChapterModel.fromFirestore(
    DocumentSnapshot doc,
    List<VerseModel> verses,
  ) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChapterModel(
      chapterNumber: data['chapter'] as int? ?? 1,
      audioPath: data['audio_path'] as String? ?? '',
      audioDurationMs: data['audio_duration_ms'] as int? ?? 0,
      verses: verses,
    );
  }
}
