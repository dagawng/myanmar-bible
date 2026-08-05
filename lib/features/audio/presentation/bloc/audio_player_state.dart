import 'package:equatable/equatable.dart';
import '../../domain/entities/audio_track.dart';

enum AudioPlayerStatus { initial, loading, playing, paused, stopped, error }

class AudioPlayerState extends Equatable {
  final AudioPlayerStatus status;
  final AudioTrack? currentTrack;
  final Duration position;
  final Duration duration;
  final double speed;
  final String? errorMessage;
  final DateTime? sleepTimerEndTime;

  const AudioPlayerState({
    this.status = AudioPlayerStatus.initial,
    this.currentTrack,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.errorMessage,
    this.sleepTimerEndTime,
  });

  bool get isPlaying => status == AudioPlayerStatus.playing || status == AudioPlayerStatus.loading;
  bool get hasTrack => currentTrack != null;

  AudioPlayerState copyWith({
    AudioPlayerStatus? status,
    AudioTrack? currentTrack,
    Duration? position,
    Duration? duration,
    double? speed,
    String? errorMessage,
    DateTime? sleepTimerEndTime,
    bool clearSleepTimer = false,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentTrack: currentTrack ?? this.currentTrack,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      errorMessage: errorMessage ?? this.errorMessage,
      sleepTimerEndTime: clearSleepTimer ? null : (sleepTimerEndTime ?? this.sleepTimerEndTime),
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentTrack,
        position,
        duration,
        speed,
        errorMessage,
        sleepTimerEndTime,
      ];
}
