import 'package:equatable/equatable.dart';
import '../../domain/entities/language.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguagesLoaded extends LanguageState {
  final List<Language> languages;
  final Language activeLanguage;
  final String searchQuery;

  const LanguagesLoaded({
    required this.languages,
    required this.activeLanguage,
    this.searchQuery = '',
  });

  List<Language> get filteredLanguages {
    if (searchQuery.trim().isEmpty) return languages;
    final query = searchQuery.toLowerCase();
    return languages.where((lang) {
      return lang.name.toLowerCase().contains(query) ||
          lang.nameEn.toLowerCase().contains(query);
    }).toList();
  }

  LanguagesLoaded copyWith({
    List<Language>? languages,
    Language? activeLanguage,
    String? searchQuery,
  }) {
    return LanguagesLoaded(
      languages: languages ?? this.languages,
      activeLanguage: activeLanguage ?? this.activeLanguage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [languages, activeLanguage, searchQuery];
}

class LanguageError extends LanguageState {
  final String message;

  const LanguageError(this.message);

  @override
  List<Object?> get props => [message];
}
