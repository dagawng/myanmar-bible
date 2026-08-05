import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;
  static const _themeModeKey = 'theme_mode';
  static const _showMiniPlayerKey = 'show_mini_player';

  SettingsCubit(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final themeModeStr = _prefs.getString(_themeModeKey);
    ThemeMode themeMode = ThemeMode.system;
    
    if (themeModeStr != null) {
      themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeModeStr,
        orElse: () => ThemeMode.system,
      );
    }
    
    final showMiniPlayer = _prefs.getBool(_showMiniPlayerKey) ?? true;

    emit(state.copyWith(
      themeMode: themeMode,
      showMiniPlayer: showMiniPlayer,
    ));
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> updateShowMiniPlayer(bool show) async {
    await _prefs.setBool(_showMiniPlayerKey, show);
    emit(state.copyWith(showMiniPlayer: show));
  }
}
