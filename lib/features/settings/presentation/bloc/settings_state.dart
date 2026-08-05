import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool? _showMiniPlayer;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    bool showMiniPlayer = true,
  }) : _showMiniPlayer = showMiniPlayer;

  bool get showMiniPlayer => _showMiniPlayer ?? true;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? showMiniPlayer,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      showMiniPlayer: showMiniPlayer ?? this.showMiniPlayer,
    );
  }

  @override
  List<Object?> get props => [themeMode, _showMiniPlayer];
}
