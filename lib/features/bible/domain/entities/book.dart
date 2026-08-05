import 'package:equatable/equatable.dart';
import '../../../../core/constants/bible_constants.dart';

class Book extends Equatable {
  final String id;
  final String languageId;
  final String name;
  final String nameEn;
  final String abbreviation;
  final int totalChapters;
  final BibleTestament testament;
  final int order;

  const Book({
    required this.id,
    required this.languageId,
    required this.name,
    required this.nameEn,
    required this.abbreviation,
    required this.totalChapters,
    required this.testament,
    required this.order,
  });

  @override
  List<Object?> get props => [
        id,
        languageId,
        name,
        nameEn,
        abbreviation,
        totalChapters,
        testament,
        order,
      ];
}
