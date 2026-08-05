import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/bible_constants.dart';
import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.id,
    required super.languageId,
    required super.name,
    required super.nameEn,
    required super.abbreviation,
    required super.totalChapters,
    required super.testament,
    required super.order,
  });

  factory BookModel.fromFirestore(DocumentSnapshot doc, String languageId) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BookModel(
      id: doc.id,
      languageId: languageId,
      name: data['name'] as String? ?? '',
      nameEn: data['name_en'] as String? ?? '',
      abbreviation: data['abbreviation'] as String? ?? '',
      totalChapters: data['total_chapters'] as int? ?? 1,
      testament: (data['testament'] as String? ?? 'old') == 'old'
          ? BibleTestament.old
          : BibleTestament.newTestament,
      order: data['order'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'name_en': nameEn,
        'abbreviation': abbreviation,
        'total_chapters': totalChapters,
        'testament': testament == BibleTestament.old ? 'old' : 'new',
        'order': order,
      };
}
