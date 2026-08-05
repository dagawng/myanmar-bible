import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/language.dart';
import '../../domain/usecases/get_active_language.dart';
import '../../domain/usecases/get_languages.dart';
import '../../domain/usecases/set_active_language.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final GetLanguages getLanguages;
  final GetActiveLanguage getActiveLanguage;
  final SetActiveLanguage setActiveLanguage;

  LanguageCubit({
    required this.getLanguages,
    required this.getActiveLanguage,
    required this.setActiveLanguage,
  }) : super(LanguageInitial());

  Future<void> loadLanguages() async {
    emit(LanguageLoading());

    final languagesResult = await getLanguages();
    final activeResult = await getActiveLanguage();

    languagesResult.fold(
      (failure) => emit(LanguageError(failure.message)),
      (languages) {
        final activeLanguage = activeResult.getOrElse(() => languages.first);
        emit(LanguagesLoaded(
          languages: languages,
          activeLanguage: activeLanguage,
        ));
      },
    );
  }

  Future<void> selectLanguage(Language language) async {
    final currentState = state;
    if (currentState is LanguagesLoaded) {
      emit(currentState.copyWith(activeLanguage: language));
      await setActiveLanguage(language.id);
    }
  }

  void filterLanguages(String query) {
    final currentState = state;
    if (currentState is LanguagesLoaded) {
      emit(currentState.copyWith(searchQuery: query));
    }
  }
}
