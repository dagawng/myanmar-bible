import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/widgets/marquee_text.dart';
import '../../../../core/utils/script_utils.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';

class AudioPlayerPage extends StatelessWidget {
  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (!state.hasTrack) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.multitrack_audio_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Audio Track Loaded',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a chapter and tap play to listen to audio narration.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final track = state.currentTrack!;
        final isPlaying = state.isPlaying;

        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minimal Drag Handle and Sleep Timer
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (state.sleepTimerEndTime != null)
                                  _SleepTimerCountdown(endTime: state.sleepTimerEndTime!),
                                IconButton(
                                  icon: Icon(
                                    Icons.bedtime_outlined,
                                    color: state.sleepTimerEndTime != null ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    _showSleepTimerOptions(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Artwork with Animated Scale & Glow
                    AnimatedScale(
                      scale: isPlaying ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.60,
                        height: MediaQuery.of(context).size.width * 0.60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colorScheme.primaryContainer,
                              colorScheme.secondaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(isPlaying ? 0.3 : 0.05),
                              blurRadius: isPlaying ? 30 : 10,
                              spreadRadius: isPlaying ? 5 : 0,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_stories_rounded,
                            size: 80,
                            color: colorScheme.primary.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Title & Subtitle with Hero-like typography
                    MarqueeText(
                      text: '${track.bookName} ${ScriptUtils.localizeNumber(track.chapterNumber, track.languageId)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Myanmar Bible Audio',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Progress Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: colorScheme.primaryContainer,
                        thumbColor: colorScheme.primary,
                        overlayColor: colorScheme.primary.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                      ),
                      child: Slider(
                        value: state.position.inSeconds.toDouble().clamp(
                              0.0,
                              state.duration.inSeconds.toDouble() > 0
                                  ? state.duration.inSeconds.toDouble()
                                  : 1.0,
                            ),
                        max: state.duration.inSeconds.toDouble() > 0
                            ? state.duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          context.read<AudioPlayerBloc>().add(
                                SeekAudioEvent(Duration(seconds: value.toInt())),
                              );
                        },
                      ),
                    ),
                    
                    // Time Indicators
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(state.position),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _formatDuration(state.duration),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Rewind
                        IconButton(
                          iconSize: 32,
                          color: colorScheme.onSurfaceVariant,
                          icon: const Icon(Icons.replay_10_rounded),
                          onPressed: () {
                            context.read<AudioPlayerBloc>().add(SkipBackwardEvent());
                          },
                        ),

                        // Play/Pause Button
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            fixedSize: const Size(76, 76),
                            shape: const CircleBorder(),
                            elevation: 4,
                            shadowColor: colorScheme.primary.withOpacity(0.4),
                          ),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              key: ValueKey<bool>(isPlaying),
                              size: 40,
                            ),
                          ),
                          onPressed: () {
                            context.read<AudioPlayerBloc>().add(TogglePlayPauseEvent());
                          },
                        ),

                        // Fast Forward
                        IconButton(
                          iconSize: 32,
                          color: colorScheme.onSurfaceVariant,
                          icon: const Icon(Icons.forward_10_rounded),
                          onPressed: () {
                            context.read<AudioPlayerBloc>().add(SkipForwardEvent());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Speed Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                            final isSelected = (state.speed - speed).abs() < 0.01;
                            return GestureDetector(
                              onTap: () {
                                context
                                    .read<AudioPlayerBloc>()
                                    .add(SetPlaybackSpeedEvent(speed));
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${speed}x',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showSleepTimerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sleep Timer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.timer_off),
                title: const Text('Off'),
                onTap: () {
                  context.read<AudioPlayerBloc>().add(const SetSleepTimerEvent(null));
                  Navigator.pop(bottomSheetContext);
                },
              ),
              ...[15, 30, 45, 60].map((minutes) => ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text('$minutes minutes'),
                    onTap: () {
                      context.read<AudioPlayerBloc>().add(SetSleepTimerEvent(Duration(minutes: minutes)));
                      Navigator.pop(bottomSheetContext);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _SleepTimerCountdown extends StatefulWidget {
  final DateTime endTime;
  const _SleepTimerCountdown({required this.endTime});

  @override
  State<_SleepTimerCountdown> createState() => _SleepTimerCountdownState();
}

class _SleepTimerCountdownState extends State<_SleepTimerCountdown> {
  late StreamSubscription _ticker;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _ticker = Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) {
        setState(() {
          _updateRemaining();
        });
      }
    });
  }

  void _updateRemaining() {
    _remaining = widget.endTime.difference(DateTime.now());
    if (_remaining.isNegative) {
      _remaining = Duration.zero;
    }
  }

  @override
  void didUpdateWidget(covariant _SleepTimerCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _updateRemaining();
    }
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) return const SizedBox.shrink();
    
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    
    return Text(
      '$minutes:$seconds',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
