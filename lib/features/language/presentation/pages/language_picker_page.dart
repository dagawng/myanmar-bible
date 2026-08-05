import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language_cubit.dart';
import '../bloc/language_state.dart';
import '../widgets/language_tile.dart';

class LanguagePickerPage extends StatelessWidget {
  const LanguagePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bible Language',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, state) {
          if (state is LanguageLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LanguageError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<LanguageCubit>().loadLanguages(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LanguagesLoaded) {
            final filtered = state.filteredLanguages;

            return Column(
              children: [
                // Material 3 Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: SearchBar(
                    hintText: 'Search languages...',
                    leading: const Icon(Icons.search_rounded),
                    onChanged: (value) {
                      context.read<LanguageCubit>().filterLanguages(value);
                    },
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(
                      colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Active info banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Available Languages (${filtered.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Language List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text('No matching languages found'),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final language = filtered[index];
                            final isSelected =
                                language.id == state.activeLanguage.id;

                            return LanguageTile(
                              language: language,
                              isSelected: isSelected,
                              onTap: () {
                                context
                                    .read<LanguageCubit>()
                                    .selectLanguage(language);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
