import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myanmar_bible_audio/core/error/failures.dart';
import 'package:myanmar_bible_audio/features/language/domain/entities/language.dart';
import 'package:myanmar_bible_audio/features/language/domain/usecases/get_active_language.dart';
import 'package:myanmar_bible_audio/features/language/domain/usecases/get_languages.dart';
import 'package:myanmar_bible_audio/features/language/domain/usecases/set_active_language.dart';
import 'package:myanmar_bible_audio/features/language/presentation/bloc/language_cubit.dart';
import 'package:myanmar_bible_audio/features/language/presentation/bloc/language_state.dart';

class MockGetLanguages extends Mock implements GetLanguages {
  @override
  Future<Either<Failure, List<Language>>> call() => super.noSuchMethod(
        Invocation.method(#call, []),
        returnValue: Future.value(const Right<Failure, List<Language>>([])),
        returnValueForMissingStub:
            Future.value(const Right<Failure, List<Language>>([])),
      );
}

class MockGetActiveLanguage extends Mock implements GetActiveLanguage {
  @override
  Future<Either<Failure, Language>> call() => super.noSuchMethod(
        Invocation.method(#call, []),
        returnValue: Future.value(const Right<Failure, Language>(tLanguage)),
        returnValueForMissingStub:
            Future.value(const Right<Failure, Language>(tLanguage)),
      );
}

class MockSetActiveLanguage extends Mock implements SetActiveLanguage {
  @override
  Future<Either<Failure, void>> call(String? languageId) => super.noSuchMethod(
        Invocation.method(#call, [languageId]),
        returnValue: Future.value(const Right<Failure, void>(null)),
        returnValueForMissingStub:
            Future.value(const Right<Failure, void>(null)),
      );
}

const tLanguage = Language(
  id: 'my_burmese',
  name: 'မြန်မာ',
  nameEn: 'Burmese',
  languageCode: 'my',
  script: 'myanmar',
  fontFamily: 'Padauk',
  hasAudio: true,
);

void main() {
  late LanguageCubit cubit;
  late MockGetLanguages mockGetLanguages;
  late MockGetActiveLanguage mockGetActiveLanguage;
  late MockSetActiveLanguage mockSetActiveLanguage;

  setUp(() {
    mockGetLanguages = MockGetLanguages();
    mockGetActiveLanguage = MockGetActiveLanguage();
    mockSetActiveLanguage = MockSetActiveLanguage();

    cubit = LanguageCubit(
      getLanguages: mockGetLanguages,
      getActiveLanguage: mockGetActiveLanguage,
      setActiveLanguage: mockSetActiveLanguage,
    );
  });

  test('initial state should be LanguageInitial', () {
    expect(cubit.state, equals(LanguageInitial()));
  });

  blocTest<LanguageCubit, LanguageState>(
    'emits [LanguageLoading, LanguagesLoaded] when loadLanguages succeeds',
    build: () {
      when(mockGetLanguages()).thenAnswer((_) async => const Right([tLanguage]));
      when(mockGetActiveLanguage())
          .thenAnswer((_) async => const Right(tLanguage));
      return cubit;
    },
    act: (cubit) => cubit.loadLanguages(),
    expect: () => [
      LanguageLoading(),
      const LanguagesLoaded(languages: [tLanguage], activeLanguage: tLanguage),
    ],
  );
}
