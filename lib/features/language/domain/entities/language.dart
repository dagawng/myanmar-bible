import 'package:equatable/equatable.dart';

class Language extends Equatable {
  final String id;
  final String name;
  final String nameEn;
  final String languageCode;
  final String script;
  final String fontFamily;
  final bool hasAudio;

  const Language({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.languageCode,
    required this.script,
    required this.fontFamily,
    required this.hasAudio,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        nameEn,
        languageCode,
        script,
        fontFamily,
        hasAudio,
      ];
}
