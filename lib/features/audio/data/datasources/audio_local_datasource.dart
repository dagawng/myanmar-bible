import '../models/audio_track_model.dart';

abstract class AudioLocalDatasource {
  Future<AudioTrackModel> getPreSeededAudioTrack({
    required String languageId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  });
}

class AudioLocalDatasourceImpl implements AudioLocalDatasource {
  // Public high-quality audio sample stream URLs for testing audio playback seamlessly
  static const String _defaultAudioStreamUrl =
      'assets/audio/sample.mp3';

  @override
  Future<AudioTrackModel> getPreSeededAudioTrack({
    required String languageId,
    required String bookId,
    required String bookName,
    required int chapterNumber,
  }) async {
    return AudioTrackModel(
      id: '${languageId}_${bookId}_$chapterNumber',
      languageId: languageId,
      bookId: bookId,
      bookName: bookName,
      chapterNumber: chapterNumber,
      audioUrl: _defaultAudioStreamUrl,
      duration: const Duration(minutes: 3, seconds: 45),
    );
  }
}
