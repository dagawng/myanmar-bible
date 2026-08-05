import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/language.dart';

class LanguageModel extends Language {
  const LanguageModel({
    required super.id,
    required super.name,
    required super.nameEn,
    required super.languageCode,
    required super.script,
    required super.fontFamily,
    required super.hasAudio,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json, String id) {
    return LanguageModel(
      id: id,
      name: json['name'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      languageCode: json['language_code'] as String? ?? 'my',
      script: json['script'] as String? ?? 'myanmar',
      fontFamily: json['font_family'] as String? ?? 'Padauk',
      hasAudio: json['has_audio'] as bool? ?? true,
    );
  }

  factory LanguageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LanguageModel.fromJson(data, doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_en': nameEn,
      'language_code': languageCode,
      'script': script,
      'font_family': fontFamily,
      'has_audio': hasAudio,
    };
  }
}
