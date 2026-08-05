import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/audio_track_model.dart';

abstract class AudioRemoteDatasource {
  Future<AudioTrackModel?> getAudioTrack({
    required String languageId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  });
}

class AudioRemoteDatasourceImpl implements AudioRemoteDatasource {
  final FirebaseFirestore? firestore;

  AudioRemoteDatasourceImpl({this.firestore});

  @override
  Future<AudioTrackModel?> getAudioTrack({
    required String languageId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      final docSnapshot = await db
          .collection(FirebaseConstants.languagesCollection)
          .doc(languageId)
          .collection(FirebaseConstants.booksCollection)
          .doc(bookId)
          .collection(FirebaseConstants.chaptersCollection)
          .doc(chapterNumber.toString())
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return AudioTrackModel(
          id: docSnapshot.id,
          languageId: languageId,
          bookId: bookId,
          bookName: bookName,
          chapterNumber: chapterNumber,
          audioUrl: data['audio_url'] as String? ?? '',
          duration: Duration(milliseconds: data['audio_duration_ms'] as int? ?? 180000),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
