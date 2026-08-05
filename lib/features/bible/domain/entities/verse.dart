import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  final int verseNumber;
  final String text;

  const Verse({
    required this.verseNumber,
    required this.text,
  });

  @override
  List<Object?> get props => [verseNumber, text];
}
