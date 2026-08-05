import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/widgets/marquee_text.dart';
import '../../../../core/utils/script_utils.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../bloc/audio_player_bloc.dart';
import '../bloc/audio_player_event.dart';
import '../bloc/audio_player_state.dart';
import '../pages/audio_player_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        if (!settingsState.showMiniPlayer) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            if (!state.hasTrack || state.status == AudioPlayerStatus.stopped) {
              return const SizedBox.shrink();
            }

            final track = state.currentTrack!;

            return Material(
              elevation: 8,
              color: colorScheme.surfaceContainerLow,
              shadowColor: colorScheme.shadow.withOpacity(0.12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      final audioBloc = context.read<AudioPlayerBloc>();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: colorScheme.surface,
                        builder: (_) => BlocProvider.value(
                          value: audioBloc,
                          child: const AudioPlayerPage(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // Audio Artwork Icon Badge
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.multitrack_audio_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Track Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MarqueeText(
                                  text: '${track.bookName} ${ScriptUtils.localizeNumber(track.chapterNumber, track.languageId)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.status == AudioPlayerStatus.loading
                                      ? 'Buffering audio stream...'
                                      : '${_formatDuration(state.position)} / ${_formatDuration(state.duration)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Play/Pause Control
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                              child: Icon(
                                state.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                key: ValueKey<bool>(state.isPlaying),
                              ),
                            ),
                            onPressed: () {
                              context
                                  .read<AudioPlayerBloc>()
                                  .add(TogglePlayPauseEvent());
                            },
                          ),
                          const SizedBox(width: 4),

                          // Dismiss / Close Button
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            color: colorScheme.onSurfaceVariant,
                            tooltip: 'Dismiss audio player',
                            onPressed: () {
                              context.read<AudioPlayerBloc>().add(StopAudioEvent());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
