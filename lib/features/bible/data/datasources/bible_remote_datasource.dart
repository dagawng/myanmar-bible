import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/book_model.dart';
import '../models/verse_model.dart';

abstract class BibleRemoteDatasource {
  Future<List<BookModel>> getBooks(String languageId);
  Future<List<VerseModel>> getVerses({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  });
}

class BibleRemoteDatasourceImpl implements BibleRemoteDatasource {
  final FirebaseFirestore? firestore;

  BibleRemoteDatasourceImpl({this.firestore});

  @override
  Future<List<BookModel>> getBooks(String languageId) async {
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      final querySnapshot = await db
          .collection(FirebaseConstants.languagesCollection)
          .doc(languageId)
          .collection(FirebaseConstants.booksCollection)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc, languageId))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<VerseModel>> getVerses({
    required String languageId,
    required String bookId,
    required int chapterNumber,
  }) async {
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      final querySnapshot = await db
          .collection(FirebaseConstants.languagesCollection)
          .doc(languageId)
          .collection(FirebaseConstants.booksCollection)
          .doc(bookId)
          .collection(FirebaseConstants.chaptersCollection)
          .doc(chapterNumber.toString())
          .collection(FirebaseConstants.versesCollection)
          .orderBy('verse')
          .get();

      return querySnapshot.docs
          .map((doc) => VerseModel.fromFirestore(doc))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
