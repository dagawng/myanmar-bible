import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/presentation/pages/main_navigation_page.dart';
import 'core/theme/app_theme.dart';
import 'features/audio/presentation/bloc/audio_player_bloc.dart';
import 'features/bible/presentation/bloc/bible_bloc.dart';
import 'features/language/presentation/bloc/language_cubit.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageCubit>(
          create: (context) => sl<LanguageCubit>()..loadLanguages(),
        ),
        BlocProvider<BibleBloc>(
          create: (context) => sl<BibleBloc>(),
        ),
        BlocProvider<AudioPlayerBloc>(
          create: (context) => sl<AudioPlayerBloc>(),
        ),
        BlocProvider<SettingsCubit>(
          create: (context) => sl<SettingsCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Myanmar Bible Audio',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            home: const MainNavigationPage(),
          );
        },
      ),
    );
  }
}
