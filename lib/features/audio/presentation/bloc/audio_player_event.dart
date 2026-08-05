import 'package:equatable/equatable.dart';
import 'audio_player_state.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayChapterAudioEvent extends AudioPlayerEvent {
  final String languageId;
  final String bookId;
  final String bookName;
  final int chapterNumber;

  const PlayChapterAudioEvent({
    required this.languageId,
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
  });

  @override
  List<Object?> get props => [languageId, bookId, bookName, chapterNumber];
}

class TogglePlayPauseEvent extends AudioPlayerEvent {}

class SeekAudioEvent extends AudioPlayerEvent {
  final Duration position;

  const SeekAudioEvent(this.position);

  @override
  List<Object?> get props => [position];
}

class SetPlaybackSpeedEvent extends AudioPlayerEvent {
  final double speed;

  const SetPlaybackSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

class SkipForwardEvent extends AudioPlayerEvent {}

class SkipBackwardEvent extends AudioPlayerEvent {}

class StopAudioEvent extends AudioPlayerEvent {}

class PauseAudioEvent extends AudioPlayerEvent {}

class SetSleepTimerEvent extends AudioPlayerEvent {
  final Duration? duration;

  const SetSleepTimerEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class AudioStatusChangedEvent extends AudioPlayerEvent {
  final AudioPlayerStatus status;

  const AudioStatusChangedEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class SetAudioDurationEvent extends AudioPlayerEvent {
  final Duration duration;

  const SetAudioDurationEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

class AudioPositionChangedEvent extends AudioPlayerEvent {
  final Duration position;

  const AudioPositionChangedEvent(this.position);

  @override
  List<Object?> get props => [position];
}
