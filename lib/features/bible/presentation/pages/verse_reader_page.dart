import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/script_utils.dart';
import '../../../../core/presentation/pages/main_navigation_page.dart';
import '../../../audio/presentation/bloc/audio_player_bloc.dart';
import '../../../audio/presentation/bloc/audio_player_event.dart';
import '../../../audio/presentation/bloc/audio_player_state.dart';
import '../../../audio/presentation/widgets/mini_player.dart';
import '../../../audio/presentation/pages/audio_player_page.dart';
import '../../../language/presentation/bloc/language_cubit.dart';
import '../../../language/presentation/bloc/language_state.dart';
import '../bloc/bible_bloc.dart';
import '../bloc/bible_event.dart';
import '../bloc/bible_state.dart';
import '../../domain/entities/book.dart';
import '../widgets/verse_text.dart';

class VerseReaderPage extends StatefulWidget {
  final Book book;
  final int chapterNumber;
  final String script;
  final String fontFamily;

  const VerseReaderPage({
    super.key,
    required this.book,
    required this.chapterNumber,
    required this.script,
    required this.fontFamily,
  });

  @override
  State<VerseReaderPage> createState() => _VerseReaderPageState();
}

class _VerseReaderPageState extends State<VerseReaderPage> {
  double _fontSize = 18.0;
  late int _currentChapter;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapterNumber;
    _loadVersesIfNeeded();
  }

  void _loadVersesIfNeeded() {
    final currentState = context.read<BibleBloc>().state;
    if (currentState is VersesLoaded &&
        currentState.book?.id == widget.book.id &&
        currentState.chapterNumber == _currentChapter &&
        currentState.verses.isNotEmpty) {
      return;
    }

    final languageState = context.read<LanguageCubit>().state;
    final langId = languageState is LanguagesLoaded
        ? languageState.activeLanguage.id
        : 'my_burmese';

    context.read<BibleBloc>().add(
          LoadVersesEvent(
            languageId: langId,
            book: widget.book,
            chapterNumber: _currentChapter,
          ),
        );
  }

  void _changeChapter(int newChapter, {bool autoPlay = false}) {
    if (newChapter < 1 || newChapter > widget.book.totalChapters) return;
    setState(() {
      _currentChapter = newChapter;
    });
    _loadVersesIfNeeded();

    if (autoPlay) {
      final languageState = context.read<LanguageCubit>().state;
      final langId = languageState is LanguagesLoaded
          ? languageState.activeLanguage.id
          : 'my_burmese';
      context.read<AudioPlayerBloc>().add(
            PlayChapterAudioEvent(
              languageId: langId,
              bookId: widget.book.id,
              bookName: widget.book.name,
              chapterNumber: _currentChapter,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
              );
            }
          },
        ),
        title: Text(
          '${widget.book.name} $_currentChapter',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Font size decrease
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: () {
              if (_fontSize > 14) setState(() => _fontSize -= 2);
            },
          ),
          // Font size increase
          IconButton(
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: () {
              if (_fontSize < 32) setState(() => _fontSize += 2);
            },
          ),
        ],
      ),
      body: BlocBuilder<BibleBloc, BibleState>(
        builder: (context, state) {
          Widget content;

          if (state is VersesLoaded &&
              state.book?.id == widget.book.id &&
              state.chapterNumber == _currentChapter) {
            content = ListView.separated(
              key: ValueKey('verses_${widget.book.id}_$_currentChapter'),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              itemCount: state.verses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final verse = state.verses[index];
                return VerseText(
                  verse: verse,
                  script: widget.script,
                  fontFamily: widget.fontFamily,
                  fontSize: _fontSize,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Selected ${widget.book.name} $_currentChapter:${verse.verseNumber}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is BibleError) {
            content = Center(
              key: const ValueKey('error'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadVersesIfNeeded,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            content = const Center(
              key: ValueKey('loading'),
              child: CircularProgressIndicator(),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: content,
          );
        },
      ),
      bottomNavigationBar: _buildChapterControlBar(colorScheme),
    );
  }

  Widget _buildChapterControlBar(ColorScheme colorScheme) {
    return Material(
      elevation: 8,
      color: colorScheme.surfaceContainerLow,
      shadowColor: colorScheme.shadow.withOpacity(0.12),
      child: SafeArea(
        top: false,
        child: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, audioState) {
            final isCurrentTrack = audioState.currentTrack?.bookId == widget.book.id &&
                audioState.currentTrack?.chapterNumber == _currentChapter;
            final isPlaying = isCurrentTrack && audioState.isPlaying;

            final hasPrevious = _currentChapter > 1;
            final hasNext = _currentChapter < widget.book.totalChapters;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    final audioBloc = context.read<AudioPlayerBloc>();
                    if (!audioBloc.state.hasTrack) {
                      final languageState = context.read<LanguageCubit>().state;
                      final langId = languageState is LanguagesLoaded
                          ? languageState.activeLanguage.id
                          : 'my_burmese';
                      audioBloc.add(
                        PlayChapterAudioEvent(
                          languageId: langId,
                          bookId: widget.book.id,
                          bookName: widget.book.name,
                          chapterNumber: _currentChapter,
                        ),
                      );
                    }
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
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 12.0),
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
                            Text(
                              '${widget.book.name} ${ScriptUtils.localizeNumber(_currentChapter, widget.book.languageId)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (isCurrentTrack)
                              Text(
                                audioState.status == AudioPlayerStatus.loading
                                    ? 'Buffering...'
                                    : '${_formatDuration(audioState.position)} / ${_formatDuration(audioState.duration)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            else
                              Text(
                                'Tap play to listen',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 28,
                            color: hasPrevious ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.3),
                            icon: const Icon(Icons.skip_previous_rounded),
                            onPressed: hasPrevious ? () => _changeChapter(_currentChapter - 1, autoPlay: isPlaying) : null,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.all(8),
                            ),
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                              child: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                key: ValueKey<bool>(isPlaying),
                                size: 24,
                              ),
                            ),
                            onPressed: () {
                              final languageState = context.read<LanguageCubit>().state;
                              final langId = languageState is LanguagesLoaded
                                  ? languageState.activeLanguage.id
                                  : 'my_burmese';

                              if (isPlaying) {
                                context.read<AudioPlayerBloc>().add(TogglePlayPauseEvent());
                              } else {
                                context.read<AudioPlayerBloc>().add(
                                      PlayChapterAudioEvent(
                                        languageId: langId,
                                        bookId: widget.book.id,
                                        bookName: widget.book.name,
                                        chapterNumber: _currentChapter,
                                      ),
                                    );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 28,
                            color: hasNext ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.3),
                            icon: const Icon(Icons.skip_next_rounded),
                            onPressed: hasNext ? () => _changeChapter(_currentChapter + 1, autoPlay: isPlaying) : null,
                          ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
