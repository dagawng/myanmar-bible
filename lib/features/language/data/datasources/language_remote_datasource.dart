import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../models/language_model.dart';

abstract class LanguageRemoteDatasource {
  Future<List<LanguageModel>> getLanguages();
}

class LanguageRemoteDatasourceImpl implements LanguageRemoteDatasource {
  final FirebaseFirestore? firestore;

  LanguageRemoteDatasourceImpl({this.firestore});

  @override
  Future<List<LanguageModel>> getLanguages() async {
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      final querySnapshot = await db
          .collection(FirebaseConstants.languagesCollection)
          .where('is_active', isEqualTo: true)
          .orderBy('order')
          .get();

      return querySnapshot.docs
          .map((doc) => LanguageModel.fromFirestore(doc))
          .toList();
    } catch (_) {
      // Returns empty list when Firebase is uninitialized or offline
      return [];
    }
  }
}
