import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_model.dart';

abstract class LanguageLocalDatasource {
  Future<List<LanguageModel>> getPreSeededLanguages();
  Future<String?> getActiveLanguageId();
  Future<void> setActiveLanguageId(String languageId);
}

class LanguageLocalDatasourceImpl implements LanguageLocalDatasource {
  static const String _activeLanguageKey = 'ACTIVE_BIBLE_LANGUAGE';
  final SharedPreferences sharedPreferences;

  LanguageLocalDatasourceImpl({required this.sharedPreferences});

  static const List<LanguageModel> defaultLanguages = [
    LanguageModel(
      id: 'my_burmese',
      name: 'မြန်မာ သမ္မာကျမ်းစာ',
      nameEn: 'Burmese Bible (Judson)',
      languageCode: 'my',
      script: 'myanmar',
      fontFamily: 'Padauk',
      hasAudio: true,
    ),
    LanguageModel(
      id: 'kachin_jinghpaw',
      name: 'Jinghpaw Chyum Laika (JCLB)',
      nameEn: 'Kachin Jinghpaw Common Language',
      languageCode: 'kcg',
      script: 'latin',
      fontFamily: 'Inter',
      hasAudio: true,
    ),
    LanguageModel(
      id: 'chin_hakha',
      name: 'Hakha Baibal',
      nameEn: 'Chin (Hakha)',
      languageCode: 'cnh',
      script: 'latin',
      fontFamily: 'Inter',
      hasAudio: true,
    ),
    LanguageModel(
      id: 'shan_shan',
      name: 'လိၵ်ႈႁူမ်ႈၵိၼ် ၽြႃး',
      nameEn: 'Shan Bible',
      languageCode: 'shn',
      script: 'shan',
      fontFamily: 'Panglong',
      hasAudio: true,
    ),
    LanguageModel(
      id: 'kayin_sgaw',
      name: 'စှီ်ဆ်ါလံာ်ကဲးဒိ ကစၢ်ယွၤ',
      nameEn: 'Sgaw Karen Bible',
      languageCode: 'ksw',
      script: 'karen',
      fontFamily: 'KarenUnicode',
      hasAudio: true,
    ),
    LanguageModel(
      id: 'kayah_li',
      name: 'ꤊꤤ꤬ꤛꤢꤩ꤬ ꤙꤤ꤬ꤛꤢꤩ꤬',
      nameEn: 'Kayah Li (Red Karen)',
      languageCode: 'kyu',
      script: 'kayah_li',
      fontFamily: 'KayahLi',
      hasAudio: true,
    ),
    LanguageModel(
      id: 'en_kjv',
      name: 'Holy Bible (KJV)',
      nameEn: 'English (King James Version)',
      languageCode: 'en',
      script: 'latin',
      fontFamily: 'Inter',
      hasAudio: true,
    ),
  ];

  @override
  Future<List<LanguageModel>> getPreSeededLanguages() async {
    return defaultLanguages;
  }

  @override
  Future<String?> getActiveLanguageId() async {
    return sharedPreferences.getString(_activeLanguageKey);
  }

  @override
  Future<void> setActiveLanguageId(String languageId) async {
    await sharedPreferences.setString(_activeLanguageKey, languageId);
  }
}
