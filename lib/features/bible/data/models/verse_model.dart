import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({
    required super.verseNumber,
    required super.text,
  });

  factory VerseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VerseModel(
      verseNumber: data['verse'] as int? ?? 1,
      text: data['text'] as String? ?? '',
    );
  }

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      verseNumber: json['verse'] as int? ?? 1,
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'verse': verseNumber,
        'text': text,
      };
}
