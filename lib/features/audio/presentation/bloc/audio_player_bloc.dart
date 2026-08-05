import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/audio_track.dart';
import '../../domain/usecases/get_audio_track.dart';
import 'audio_player_event.dart';
import 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final GetAudioTrack getAudioTrack;
  final AudioPlayer _audioPlayer;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;
  Timer? _sleepTimer;

  AudioPlayerBloc({
    required this.getAudioTrack,
    AudioPlayer? audioPlayer,
  })  : _audioPlayer = audioPlayer ?? AudioPlayer(),
        super(const AudioPlayerState()) {
    on<PlayChapterAudioEvent>(_onPlayChapterAudio);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<SeekAudioEvent>(_onSeekAudio);
    on<SetPlaybackSpeedEvent>(_onSetPlaybackSpeed);
    on<SkipForwardEvent>(_onSkipForward);
    on<SkipBackwardEvent>(_onSkipBackward);
    on<StopAudioEvent>(_onStopAudio);
    on<PauseAudioEvent>(_onPauseAudio);
    on<SetSleepTimerEvent>(_onSetSleepTimer);

    on<SetAudioDurationEvent>(_onSetAudioDuration);
    on<AudioStatusChangedEvent>(_onAudioStatusChanged);
    on<AudioPositionChangedEvent>(_onAudioPositionChanged);

    _listenToPlayerStreams();
  }

  void _listenToPlayerStreams() {
    _positionSubscription = _audioPlayer.positionStream.listen((pos) {
      add(AudioPositionChangedEvent(pos));
    });

    _durationSubscription = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        add(SetAudioDurationEvent(dur));
      }
    });

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        add(const AudioStatusChangedEvent(AudioPlayerStatus.stopped));
      } else if (processingState == ProcessingState.buffering || processingState == ProcessingState.loading) {
        add(const AudioStatusChangedEvent(AudioPlayerStatus.loading));
      } else if (isPlaying) {
        add(const AudioStatusChangedEvent(AudioPlayerStatus.playing));
      } else if (state.status != AudioPlayerStatus.initial && state.status != AudioPlayerStatus.stopped) {
        add(const AudioStatusChangedEvent(AudioPlayerStatus.paused));
      }
    });
  }

  void _onSetAudioDuration(
    SetAudioDurationEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onAudioPositionChanged(
    AudioPositionChangedEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onAudioStatusChanged(
    AudioStatusChangedEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (event.status == AudioPlayerStatus.stopped) {
      emit(state.copyWith(status: event.status, position: Duration.zero));
    } else {
      emit(state.copyWith(status: event.status));
    }
  }

  Future<void> _onPlayChapterAudio(
    PlayChapterAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final tempTrack = AudioTrack(
      id: 'loading_${event.bookId}_${event.chapterNumber}',
      languageId: event.languageId,
      bookId: event.bookId,
      bookName: event.bookName,
      chapterNumber: event.chapterNumber,
      audioUrl: '',
      duration: Duration.zero,
    );
    emit(state.copyWith(
      status: AudioPlayerStatus.loading,
      currentTrack: tempTrack,
    ));

    final result = await getAudioTrack(GetAudioTrackParams(
      languageId: event.languageId,
      bookId: event.bookId,
      bookName: event.bookName,
      chapterNumber: event.chapterNumber,
    ));

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: AudioPlayerStatus.error,
          errorMessage: failure.message,
        ));
      },
      (track) async {
        try {
          if (track.audioUrl.startsWith('assets/')) {
            await _audioPlayer.setAsset(track.audioUrl);
          } else {
            await _audioPlayer.setUrl(track.audioUrl);
          }
          _audioPlayer.play();
          emit(state.copyWith(
            status: AudioPlayerStatus.playing,
            currentTrack: track,
            duration: _audioPlayer.duration ?? track.duration,
          ));
        } catch (e) {
          emit(state.copyWith(
            status: AudioPlayerStatus.error,
            errorMessage: 'Failed to stream audio: $e',
          ));
        }
      },
    );
  }

  Future<void> _onTogglePlayPause(
    TogglePlayPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (_audioPlayer.playing || state.status == AudioPlayerStatus.playing) {
      await _audioPlayer.pause();
      emit(state.copyWith(status: AudioPlayerStatus.paused));
    } else {
      emit(state.copyWith(status: AudioPlayerStatus.playing));
      _audioPlayer.play();
    }
  }

  Future<void> _onSeekAudio(
    SeekAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _audioPlayer.seek(event.position);
    emit(state.copyWith(position: event.position));
  }

  Future<void> _onSetPlaybackSpeed(
    SetPlaybackSpeedEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _audioPlayer.setSpeed(event.speed);
    emit(state.copyWith(speed: event.speed));
  }

  Future<void> _onSkipForward(
    SkipForwardEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final newPos = state.position + const Duration(seconds: 10);
    final target = newPos > state.duration ? state.duration : newPos;
    await _audioPlayer.seek(target);
  }

  Future<void> _onSkipBackward(
    SkipBackwardEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final newPos = state.position - const Duration(seconds: 10);
    final target = newPos < Duration.zero ? Duration.zero : newPos;
    await _audioPlayer.seek(target);
  }

  Future<void> _onStopAudio(
    StopAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    await _audioPlayer.stop();
    emit(state.copyWith(status: AudioPlayerStatus.stopped));
  }

  Future<void> _onPauseAudio(
    PauseAudioEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      emit(state.copyWith(status: AudioPlayerStatus.paused));
    }
  }

  Future<void> _onSetSleepTimer(
    SetSleepTimerEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    if (event.duration == null) {
      emit(state.copyWith(clearSleepTimer: true));
    } else {
      _sleepTimer = Timer(event.duration!, () {
        add(PauseAudioEvent());
        add(const SetSleepTimerEvent(null));
      });
      emit(state.copyWith(
        sleepTimerEndTime: DateTime.now().add(event.duration!),
      ));
    }
  }

  @override
  Future<void> close() {
    _sleepTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
