import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/audio/presentation/widgets/mini_player.dart';
import '../../../features/bible/presentation/pages/book_list_page.dart';
import '../../../features/language/presentation/pages/language_picker_page.dart';
import '../../../features/settings/presentation/bloc/settings_cubit.dart';
import '../../../features/settings/presentation/bloc/settings_state.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BookListPage(),
    _PlaceholderPage(
      title: 'Search Bible',
      icon: Icons.search_rounded,
      subtitle: 'Search across all Bible text and audio tracks.',
    ),
    _PlaceholderPage(
      title: 'Study & Library',
      icon: Icons.collections_bookmark_rounded,
      subtitle: 'Your saved bookmarks, highlights, notes, and downloads.',
    ),
    _SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Bible',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                selectedIcon: Icon(Icons.collections_bookmark_rounded),
                label: 'Study',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Theme Mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.brightness_auto_rounded),
                    title: const Text('System Default'),
                    trailing: state.themeMode == ThemeMode.system
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      context.read<SettingsCubit>().updateThemeMode(ThemeMode.system);
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.light_mode_rounded),
                    title: const Text('Light'),
                    trailing: state.themeMode == ThemeMode.light
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      context.read<SettingsCubit>().updateThemeMode(ThemeMode.light);
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_rounded),
                    title: const Text('Dark'),
                    trailing: state.themeMode == ThemeMode.dark
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      context.read<SettingsCubit>().updateThemeMode(ThemeMode.dark);
                      Navigator.pop(bottomSheetContext);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Bible Language'),
                subtitle: const Text('Burmese, Kachin, Chin, Shan, Karen, Kayah, English'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LanguagePickerPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dark_mode_rounded),
                title: const Text('Theme Mode'),
                subtitle: Text(_getThemeModeName(state.themeMode)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showThemePicker(context),
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.music_note_rounded),
                title: const Text('Show Audio Mini-Player'),
                subtitle: const Text('Display persistent floating player at screen bottom'),
                value: state.showMiniPlayer,
                onChanged: (value) {
                  context.read<SettingsCubit>().updateShowMiniPlayer(value);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.download_for_offline_rounded),
                title: const Text('Downloaded Audio'),
                subtitle: const Text('Manage offline Bible audio chapters'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
